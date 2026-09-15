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



