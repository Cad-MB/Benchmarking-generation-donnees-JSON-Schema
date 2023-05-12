import argparse
import json
from jschon import create_catalog, JSON, JSONSchema
from jschon.catalog import CatalogError

JSONSchema.DEFAULT_METASCHEMA_URI = 'https://json-schema.org/draft/2020-12/schema'

parser = argparse.ArgumentParser(description='JSON schema validation.')
parser.add_argument('schema', metavar='schema', type=str,
                    help='JSON schema string')
parser.add_argument('instance', metavar='instance', type=str,
                    help='JSON instance string')

args = parser.parse_args()

try:
    create_catalog('2020-12')
except CatalogError as e:
    print(json.dumps({"exception": type(e).__name__, "message": str(e)}))
    exit(1)

schema_data = json.loads(args.schema)
schema_data["$schema"] = "https://json-schema.org/draft/2020-12/schema"
demo_schema = JSONSchema(schema_data)

result = demo_schema.evaluate(
    JSON(json.loads(args.instance))
)

data_valid = json.loads(json.dumps(result.output('flag')))
valid = data_valid["valid"]

data_errors = json.loads(json.dumps(result.output('detailed')))
r_errors = data_errors
r_details = data_errors

def get_last_keyword_location(r_errors):
    if "errors" in r_errors and len(r_errors["errors"]) > 0:
        return get_last_keyword_location(r_errors["errors"][0])
    elif "keywordLocation" in r_errors:
        return r_errors["keywordLocation"]
    else:
        return "/Server error"

def get_last_error(r_details):
    if "errors" in r_details and len(r_details["errors"]) > 0:
        return get_last_error(r_details["errors"][0])
    elif "error" in r_details:
        return r_details["error"]
    else:
        return "Server error"

print(valid, get_last_keyword_location(r_errors), get_last_error(r_details))
