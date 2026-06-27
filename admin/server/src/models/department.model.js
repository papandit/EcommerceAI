const mongoose = require('mongoose');
const { baseSchemaOptions } = require('../utils/baseSchema');

/** Departments — Firestore "department" shape (dept_name / last_name). */
const departmentSchema = new mongoose.Schema(
  {
    dept_name: { type: String, default: '' },
    last_name: { type: String, default: '' },
  },
  baseSchemaOptions
);

module.exports = mongoose.model('Department', departmentSchema, 'departments');
