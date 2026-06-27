/**
 * Shared Mongoose schema options so every model serializes the same way:
 *  - `_id` (ObjectId) is exposed as a string `id` (and `Id`, since some Flutter
 *    models read the capitalized `Id` key) — matching the old Firestore shape.
 *  - `__v` is removed.
 *  - timestamps add createdAt/updatedAt; we also surface capitalized aliases
 *    (CreatedAt/UpdatedAt) in the transform because several models read those.
 *  - Dates serialize to ISO-8601 strings (default JSON behavior), which the
 *    Flutter models already parse.
 */
function transform(doc, ret) {
  ret.id = String(ret._id);
  ret.Id = ret.id;
  if (ret.createdAt && !ret.CreatedAt) ret.CreatedAt = ret.createdAt;
  if (ret.updatedAt && !ret.UpdatedAt) ret.UpdatedAt = ret.updatedAt;
  delete ret._id;
  delete ret.__v;
  return ret;
}

const baseSchemaOptions = {
  timestamps: true,
  toJSON: { virtuals: true, versionKey: false, transform },
  toObject: { virtuals: true, versionKey: false, transform },
  // store unspecified keys too (defensive for legacy/extra fields)
  minimize: false,
};

module.exports = { baseSchemaOptions };
