import argparse
import json
from jschon import create_catalog, JSON, JSONSchema

JSONSchema.DEFAULT_METASCHEMA_URI = 'https://json-schema.org/draft/2020-12/schema'

parser = argparse.ArgumentParser(description='JSON schema validation.')
parser.add_argument('schema', metavar='schema', type=str,
                    help='JSON schema string')
parser.add_argument('instance', metavar='instance', type=str,
                    help='JSON instance string')

args = parser.parse_args()

create_catalog('2020-12')

schema_data = json.loads(args.schema)
schema_data["$schema"] = "https://json-schema.org/draft/2020-12/schema"
demo_schema = JSONSchema(schema_data)

result = demo_schema.evaluate(
    JSON(json.loads(args.instance))
)

data = json.loads(json.dumps(result.output('flag')))
valid = data["valid"]

errors = result.output('basic')

print(valid, errors)
