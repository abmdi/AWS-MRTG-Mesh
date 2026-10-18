#!/usr/bin/env python3
import boto3
import sys

def audit_tgw_routes(region):
    print(f"[*] Auditing Transit Gateway Route Tables in region: {region}...")
    client = boto3.client('ec2', region_name=region)
    
    try:
        response = client.describe_transit_gateways()
        tgws = response.get('TransitGateways', [])
        
        if not tgws:
            print(f"[!] No Transit Gateways found in {region}.")
            return
            
        for tgw in tgws:
            tgw_id = tgw['TransitGatewayId']
            print(f" -> Found TGW ID: {tgw_id} (State: {tgw['State']})")
            
            # Describe TGW Route Tables
            rt_response = client.describe_transit_gateway_route_tables(
                Filters=[{'Name': 'transit-gateway-id', 'Values': [tgw_id]}]
            )
            for rt in rt_response.get('TransitGatewayRouteTables', []):
                rt_id = rt['TransitGatewayRouteTableId']
                print(f"    - Route Table ID: {rt_id}")
                
                routes = client.search_transit_gateway_routes(
                    TransitGatewayRouteTableId=rt_id,
                    Filters=[{'Name': 'state', 'Values': ['active']}]
                )
                for route in routes.get('Routes', []):
                    print(f"      * Destination: {route.get('DestinationCidrBlock')} | Type: {route.get('Type')} | State: {route.get('State')}")
                    
    except Exception as e:
        print(f"[ERROR] Failed to fetch TGW data in {region}: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    print("=====================================================")
    print("      AWS Multi-Region TGW Mesh Route Auditor        ")
    print("=====================================================")
    audit_tgw_routes("us-east-1")
    audit_tgw_routes("eu-west-1")
    print("[SUCCESS] TGW Route audit completed successfully.")
