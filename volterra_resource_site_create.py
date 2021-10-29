#!/usr/bin/env python3

import os
import sys
import json
import argparse
import urllib.request

from urllib.error import HTTPError


def get_tenant_id(tenant, token):
    headers = {
        "Authorization": "APIToken %s" % token
    }
    try:
        url = "https://%s.console.ves.volterra.io/api/web/namespaces/system" % tenant
        request = urllib.request.Request(
            url, headers=headers, method='GET')
        response = urllib.request.urlopen(request)
        return json.load(response)['system_metadata']['tenant']
    except HTTPError as her:
        sys.stderr.write(
            "Error retrieving tenant ID - %s\n" % her)
        sys.exit(1)


def assure_site_token(tenant, token, site_token_name):
    site_token_name = site_token_name.encode('utf-8').decode('utf-8')
    headers = {
        "Authorization": "APIToken %s" % token
    }
    # Does the site token exist
    try:
        url = "https://%s.console.ves.volterra.io/api/register/namespaces/system/tokens/%s" % (
            tenant, site_token_name)
        request = urllib.request.Request(
            url, headers=headers, method='GET')
        response = urllib.request.urlopen(request)
        return json.load(response)['system_metadata']['uid']
    except HTTPError as her:
        if her.code == 404:
            try:
                url = "https://%s.console.ves.volterra.io/api/register/namespaces/system/tokens" % tenant
                headers['volterra-apigw-tenant'] = tenant
                headers['content-type'] = 'application/json'
                data = {
                    "metadata": {
                        "annotations": {},
                        "description": "Site Authorization Token for %s" % site_token_name,
                        "disable": False,
                        "labels": {},
                        "name": site_token_name,
                        "namespace": "system"
                    },
                    "spec": {}
                }
                data = json.dumps(data)
                request = urllib.request.Request(
                    url=url, headers=headers, data=bytes(data.encode('utf-8')), method='POST')
                response = urllib.request.urlopen(request)
                site_token = json.load(response)
                return site_token['system_metadata']['uid']
            except HTTPError as err:
                sys.stderr.write(
                    "Error creating site token resources %s: %s\n" % (url, err))
                sys.exit(1)
        else:
            sys.stderr.write(
                "Error retrieving site token resources %s: %s\n" % (url, her))
            sys.exit(1)
    except Exception as er:
        sys.stderr.write(
            "Error retrieving site token resources %s\n" % er)
        sys.exit(1)


def assure_network_connector(tenant, token, site_name, fleet_label):
    headers = {
        "Authorization": "APIToken %s" % token
    }
    # Does Global Network connector exist?
    try:
        url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/network_connectors/%s" % (
            tenant, site_name)
        request = urllib.request.Request(
            url, headers=headers, method='GET')
        urllib.request.urlopen(request)
    except HTTPError as her:
        if her.code == 404:
            try:
                url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/network_connectors" % tenant
                headers['volterra-apigw-tenant'] = tenant
                headers['content-type'] = 'application/json'
                data = {
                    "namespace": "system",
                    "metadata": {
                        "name": site_name,
                        "namespace": None,
                        "labels": {
                            "ves.io/fleet": fleet_label
                        },
                        "annotations": {},
                        "description": "connecting %s to the global shared network" % site_name,
                        "disable": False
                    },
                    "spec": {
                        "sli_to_global_dr": {
                            "global_vn": {
                                "tenant": "ves-io",
                                "namespace": "shared",
                                "name": "public"
                            }
                        },
                        "disable_forward_proxy": {}
                    }
                }
                data = json.dumps(data)
                request = urllib.request.Request(
                    url=url, headers=headers, data=bytes(data.encode('utf-8')), method='POST')
                urllib.request.urlopen(request)
            except HTTPError as her:
                sys.stderr.write(
                    "Error creating network_connectors resources %s: %s - %s\n" % (url, data, her))
                sys.exit(1)
        else:
            sys.stderr.write(
                "Error retrieving network_connectors resources %s: %s\n" % (url, her))
            sys.exit(1)


def assure_fleet(tenant, token, site_name, fleet_label, tenant_id):
    headers = {
        "Authorization": "APIToken %s" % token
    }
    # Does the fleet exist
    try:
        url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/fleets/%s" % (
            tenant, site_name)
        request = urllib.request.Request(
            url, headers=headers, method='GET')
        response = urllib.request.urlopen(request)
        return json.load(response)['spec']['fleet_label']
    except HTTPError as her:
        if her.code == 404:
            try:
                url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/fleets" % tenant
                headers['volterra-apigw-tenant'] = tenant
                headers['content-type'] = 'application/json'
                data = {
                    "namespace": "system",
                    "metadata": {
                        "name": site_name,
                        "namespace": None,
                        "labels": {},
                        "annotations": {},
                        "description": "Fleet provisioning object for %s" % site_name,
                        "disable": None
                    },
                    "spec": {
                        "fleet_label": fleet_label,
                        "volterra_software_version": None,
                        "network_connectors": [
                            {
                                "kind": "network_connector",
                                "uuid": None,
                                "tenant": tenant_id,
                                "namespace": "system",
                                "name": site_name
                            }
                        ],
                        "network_firewall": None,
                        "operating_system_version": None,
                        "outside_virtual_network": None,
                        "inside_virtual_network": [],
                        "default_config": {},
                        "no_bond_devices": {},
                        "no_storage_interfaces": {},
                        "no_storage_device": {},
                        "default_storage_class": {},
                        "no_dc_cluster_group": {},
                        "disable_gpu": {},
                        "no_storage_static_routes": {},
                        "enable_default_fleet_config_download": None,
                        "logs_streaming_disabled": {},
                        "deny_all_usb": {}
                    }
                }
                data = json.dumps(data)
                request = urllib.request.Request(
                    url=url, headers=headers, data=bytes(data.encode('utf-8')), method='POST')
                response = urllib.request.urlopen(request)
                return json.load(response)['spec']['fleet_label']
            except HTTPError as her:
                sys.stderr.write(
                    "Error creating fleets resources %s: %s - %s\n" % (url, data, her))
                sys.exit(1)
        else:
            sys.stderr.write(
                "Error retrieving feet resources %s: %s\n" % (url, her))
            sys.exit(1)
    except Exception as er:
        sys.stderr.write(
            "Error retrieving fleet resources %s\n" % er)
        sys.exit(1)


def main():
    ap = argparse.ArgumentParser(
        prog='volterra_resource_site_destroy',
        usage='%(prog)s.py [options]',
        description='clean up site tokens and fleets on destroy'
    )
    ap.add_argument(
        '--site',
        help='Volterra site name',
        required=True
    )
    ap.add_argument(
        '--fleet',
        help='Volterra fleet label',
        required=True
    )
    ap.add_argument(
        '--tenant',
        help='Volterra site tenant',
        required=True
    )
    ap.add_argument(
        '--token',
        help='Volterra API token',
        required=True
    )
    args = ap.parse_args()

    tenant_id = get_tenant_id(
        args.tenant,
        args.token
    )
    assure_network_connector(
        args.tenant,
        args.token,
        args.site,
        args.fleet
    )
    assure_fleet(
        args.tenant,
        args.token,
        args.site,
        args.fleet,
        tenant_id
    )
    site_token = assure_site_token(
        args.tenant,
        args.token,
        args.site
    )
    site_token_file = "%s/%s_site_token.txt" % (
        os.path.dirname(os.path.realpath(__file__)), args.site)
    if os.path.exists(site_token_file):
        os.unlink(site_token_file)
    with open(site_token_file, "w") as site_token_file:
        site_token_file.write(site_token)
    sys.stdout.write(
        'Created registration token for the site: %s' % site_token)
    sys.exit(0)


if __name__ == '__main__':
    main()
