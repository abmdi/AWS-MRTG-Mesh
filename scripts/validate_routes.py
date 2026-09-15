#!/usr/bin/env python3
"""
AWS-MRTG-Mesh: Route Validation & Dynamic Monitoring Script
Author: Abbas Moradi
Description: Inspects TGW Route Tables across AWS regions to ensure
             inter-region connectivity and flag invalid/blackhole routes.
"""

import sys
import json
import argparse
import boto3
from botocore.exceptions import BotoCoreError, ClientError
from tabulate import tabulate


def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Validate AWS Multi-Region Transit Gateway routes and peering state."
    )
    parser.add_argument(
        "--primary-region",
        default="us-east-1",
        help="Primary AWS Region (default: us-east-1)"
    )
    parser.add_argument(
        "--secondary-region",
        default="eu-west-1",
        help="Secondary AWS Region (default: eu-west-1)"
    )
    parser.add_argument(
        "--json-output",
        action="store_true",
        help="Render report strictly as formatted JSON"
    )
    return parser.parse_args()


def get_tgw_route_tables(ec2_client):
    """Fetches all Transit Gateway Route Tables in the specified region."""
    try:
        response = ec2_client.describe_transit_gateway_route_tables()
        return response.get("TransitGatewayRouteTables", [])
    except ClientError as err:
        print(f"[ERROR] AWS API Call failed: {err}", file=sys.stderr)
        return []


def inspect_tgw_routes(ec2_client, tgw_rt_id):
    """Queries active and blackhole routes within a specific TGW Route Table."""
    try:
        response = ec2_client.search_transit_gateway_routes(
            TransitGatewayRouteTableId=tgw_rt_id,
            Filters=[
                {'Name': 'state', 'Values': ['active', 'blackhole']}
            ]
        )
        return response.get("Routes", [])
    except ClientError as err:
        print(f"[ERROR] Failed to search routes for RT {tgw_rt_id}: {err}", file=sys.stderr)
        return []


def inspect_peering_attachments(ec2_client):
    """Checks for existing TGW Peering Attachments and verifies their state."""
    try:
        response = ec2_client.describe_transit_gateway_peering_attachments()
        attachments = response.get("TransitGatewayPeeringAttachments", [])
        results = []
        for att in attachments:
            results.append({
                "AttachmentId": att.get("TransitGatewayAttachmentId"),
                "State": att.get("State"),
                "RequesterRegion": att.get("RequesterTgwInfo", {}).get("Region"),
                "AccepterRegion": att.get("AccepterTgwInfo", {}).get("Region"),
            })
        return results
    except ClientError as err:
        print(f"[ERROR] Failed to fetch TGW Peering Attachments: {err}", file=sys.stderr)
        return []

def audit_region_routing(region_name):
    """Executes full audit pipeline for a given region."""
    session = boto3.Session(region_name=region_name)
    ec2_client = session.client("ec2")

    route_tables = get_tgw_route_tables(ec2_client)
    peering_status = inspect_peering_attachments(ec2_client)
    
    audit_data = {
        "Region": region_name,
        "PeeringAttachments": peering_status,
        "RouteTables": []
    }

    for rt in route_tables:
        rt_id = rt.get("TransitGatewayRouteTableId")
        routes = inspect_tgw_routes(ec2_client, rt_id)
        
        parsed_routes = []
        for r in routes:
            parsed_routes.append({
                "Destination": r.get("DestinationCidrBlock"),
                "Type": r.get("Type"),
                "State": r.get("State"),
                "AttachmentId": r.get("TransitGatewayAttachments", [{}])[0].get("TransitGatewayAttachmentId", "N/A")
            })

        audit_data["RouteTables"].append({
            "RouteTableId": rt_id,
            "Routes": parsed_routes
        })

    return audit_data

def main():
    args = parse_arguments()

    try:
        primary_audit = audit_region_routing(args.primary_region)
        secondary_audit = audit_region_routing(args.secondary_region)
    except (BotoCoreError, Exception) as error:
        print(f"[CRITICAL] Execution interrupted: {error}", file=sys.stderr)
        sys.exit(1)

    combined_report = {
        "PrimaryRegion": primary_audit,
        "SecondaryRegion": secondary_audit
    }

    if args.json_output:
        print(json.dumps(combined_report, indent=2))
        return

    # Console CLI Standard Output Formatting
    print("=" * 80)
    print(" AWS-MRTG-Mesh: Multi-Region Route Validation Report")
    print("=" * 80)

    for audit in [primary_audit, secondary_audit]:
        print(f"\n[+] Region: {audit['Region']}")
        
        # Display Peering Attachment Status
        print("\n  --> Peering Attachment Status:")
        if audit["PeeringAttachments"]:
            peering_table = [
                [p["AttachmentId"], p["State"], p["RequesterRegion"], p["AccepterRegion"]]
                for p in audit["PeeringAttachments"]
            ]
            print(tabulate(peering_table, headers=["Attachment ID", "State", "Requester", "Accepter"], tablefmt="square"))
        else:
            print("      No Peering Attachments found.")

        # Display Route Tables Status
        print("\n  --> Transit Gateway Route Tables:")
        for rt in audit["RouteTables"]:
            print(f"      Table ID: {rt['RouteTableId']}")
            if rt["Routes"]:
                routes_table = [
                    [r["Destination"], r["Type"], r["State"], r["AttachmentId"]]
                    for r in rt["Routes"]
                ]
                print(tabulate(routes_table, headers=["Destination", "Type", "State", "Attachment ID"], tablefmt="presto"))
            else:
                print("      No active or blackhole routes.")
            print()

    print("=" * 80)
    print(" Audit Execution Finished Successfully.")
    print("=" * 80)


if __name__ == "__main__":
    main()


