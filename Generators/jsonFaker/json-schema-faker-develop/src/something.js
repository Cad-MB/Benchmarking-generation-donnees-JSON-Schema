import { JSONSchemaFaker } from './shared.js';

const schema = {
  "additionalProperties": false,
  "minProperties": 3,
  "properties": {
    "first": {
      "type": "number"
    },
    "second": {
      "type": "string"
    },
    "third": {
      "type": "null"
    },
    "fourth": {
      "type": "object"
    }
  },
  "required": [
    "first"
  ],
  "type": "object"
};
// sync-version (blocking)

let sample = JSONSchemaFaker.generate(schema);// [object Object]

console.log(sample);
