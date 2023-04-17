import { getDependencies } from './vendor.mjs';
import Container from './class/Container.mjs';
import format from './api/format.mjs';
import option from './api/option.mjs';
import env from './core/constants.mjs';
import random from './core/random.mjs';
import utils from './core/utils.mjs';
import run from './core/run.mjs';
import { renderJS, renderYAML } from './renderers/index.mjs';

const container = new Container();

function setupKeywords() {
  // safe auto-increment values
  container.define('autoIncrement', function autoIncrement(value, schema) {
    if (!this.offset) {
      const min = schema.minimum || 1;
      const max = min + env.MAX_NUMBER;
      const offset = value.initialOffset || schema.initialOffset;

      this.offset = offset || random.number(min, max);
    }

    if (value === true) {
      return this.offset++; // eslint-disable-line
    }

    return schema;
  });

  // safe-and-sequential dates
  container.define('sequentialDate', function sequentialDate(value, schema) {
    if (!this.now) {
      this.now = random.date();
    }

    if (value) {
      schema = this.now.toISOString();
      value = value === true
        ? 'days'
        : value;

      if (['seconds', 'minutes', 'hours', 'days', 'weeks', 'months', 'years'].indexOf(value) === -1) {
        throw new Error(`Unsupported increment by ${utils.short(value)}`);
      }

      this.now.setTime(this.now.getTime() + random.date(value));
    }

    return schema;
  });
}

function getRefs(refs, schema) {
  let $refs = {};

  if (Array.isArray(refs)) {
    refs.forEach(_schema => {
      $refs[_schema.$id || _schema.id] = _schema;
    });
  } else {
    $refs = refs || {};
  }

  function walk(obj) {
    if (!obj || typeof obj !== 'object') return;
    if (Array.isArray(obj)) return obj.forEach(walk);

    const _id = obj.$id || obj.id;

    if (typeof _id === 'string' && !$refs[_id]) {
      $refs[_id] = obj;
    }

    Object.keys(obj).forEach(key => {
      walk(obj[key]);
    });
  }

  walk(refs);
  walk(schema);

  return $refs;
}

const jsf = (schema, refs, cwd) => {
  console.debug('[json-schema-faker] calling JSONSchemaFaker() is deprecated, call either .generate() or .resolve()');

  if (cwd) {
    console.debug('[json-schema-faker] local references are only supported by calling .resolve()');
  }

  return jsf.generate(schema, refs);
};

jsf.generateWithContext = (schema, refs) => {
  const $refs = getRefs(refs, schema);

  return run($refs, schema, container, true);
};

jsf.generate = (schema, refs) => renderJS(
    jsf.generateWithContext(schema, refs),
  );

jsf.generateYAML = (schema, refs) => renderYAML(
    jsf.generateWithContext(schema, refs),
  );

jsf.resolveWithContext = (schema, refs, cwd) => {
  if (typeof refs === 'string') {
    cwd = refs;
    refs = {};
  }

  // normalize basedir (browser aware)
  cwd = cwd || (typeof process !== 'undefined' ? process.cwd() : '');
  cwd = `${cwd.replace(/\/+$/, '')}/`;

  const $refs = getRefs(refs, schema);

  // identical setup as json-schema-sequelizer
  const fixedRefs = {
    order: 1,
    canRead(file) {
      const key = file.url.replace('/:', ':');

      return $refs[key] || $refs[key.split('/').pop()];
    },
    read(file, callback) {
      try {
        callback(null, this.canRead(file));
      } catch (e) {
        callback(e);
      }
    },
  };

  const { $RefParser } = getDependencies();

  return $RefParser
    .bundle(cwd, schema, {
      resolve: {
        file: { order: 100 },
        http: { order: 200 },
        fixedRefs,
      },
      dereference: {
        circular: 'ignore',
      },
    }).then(sub => run($refs, sub, container))
    .catch(e => {
      throw new Error(`Error while resolving schema (${e.message})`);
    });
};

jsf.resolve = (schema, refs, cwd) => jsf.resolveWithContext(schema, refs, cwd).then(renderJS);

jsf.resolveYAML = (schema, refs, cwd) => jsf.resolveWithContext(schema, refs, cwd).then(renderYAML);

setupKeywords();

jsf.format = format;
jsf.option = option;
jsf.random = random;

// returns itself for chaining
jsf.extend = (name, cb) => {
  container.extend(name, cb);
  return jsf;
};

jsf.define = (name, cb) => {
  container.define(name, cb);
  return jsf;
};

jsf.reset = name => {
  container.reset(name);
  setupKeywords();
  return jsf;
};

jsf.locate = name => {
  return container.get(name);
};

jsf.VERSION = process.env.VERSION || 'HEAD';

// Export an object that has all of jsf()'s properties and is not a function
// Calling jsf() is deprecated in favor of JSONSchemaFaker.generate() / JSONSchemaFaker.resolve()
export const JSONSchemaFaker = { ...jsf };

// For backward compatibility we still export the jsf function
export default jsf;
