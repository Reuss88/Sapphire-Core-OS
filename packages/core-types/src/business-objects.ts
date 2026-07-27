export type ArchitectureStatus =
  | "draft"
  | "in_review"
  | "approved"
  | "effective"
  | "locked"
  | "retired"
  | "superseded";

export type ProvenanceKind =
  | "human_entry"
  | "external_integration"
  | "dataset_import"
  | "document_extraction"
  | "system_calculation"
  | "ai_assisted_preparation"
  | "authorised_automation"
  | "migration"
  | "correction";

export interface EffectivePeriod {
  effectiveFrom: string;
  effectiveTo?: string | null;
}

export interface BusinessObjectTypeDefinition {
  id: string;
  typeKey: string;
  canonicalName: string;
  description: string;
  objectFamily: string;
  architectureStatus: ArchitectureStatus;
  architectureVersion: string;
  identityStrategy: Record<string, unknown>;
  ownershipModel: Record<string, unknown>;
  classificationRules: Record<string, unknown>;
  attributeSchema: Record<string, unknown>;
  lifecyclePolicy: Record<string, unknown>;
  relationshipPolicy: Record<string, unknown>;
  provenanceRequirements: Record<string, unknown>;
  retentionPolicy: Record<string, unknown>;
  versioningPolicy: Record<string, unknown>;
  implementationMappings: Record<string, unknown>;
  effectiveFrom?: string | null;
  effectiveTo?: string | null;
}

export interface BusinessObjectIdentity {
  id: string;
  organisationId: string;
  objectTypeId: string;
  displayLabel: string;
  ownerActorId?: string | null;
  classificationKey?: string | null;
  currentVersionNo: number;
  currentLifecycleStateKey?: string | null;
  isActive: boolean;
  createdAt: string;
  createdBy?: string | null;
  retiredAt?: string | null;
  retiredBy?: string | null;
}

export interface BusinessObjectVersion<TData extends Record<string, unknown> = Record<string, unknown>> {
  id: string;
  businessObjectId: string;
  versionNo: number;
  data: TData;
  effectiveFrom: string;
  effectiveTo?: string | null;
  recordedAt: string;
  recordedBy?: string | null;
  provenanceKind: ProvenanceKind;
  provenanceRef?: string | null;
  changeReason?: string | null;
  supersedesVersionId?: string | null;
  contentHash: string;
}

export interface BusinessObjectIdentifier {
  id: string;
  businessObjectId: string;
  namespace: string;
  identifierValue: string;
  sourceSystem?: string | null;
  isPrimary: boolean;
  effectiveFrom: string;
  effectiveTo?: string | null;
  recordedAt: string;
  recordedBy?: string | null;
}

export interface BusinessObjectSnapshot<TData extends Record<string, unknown> = Record<string, unknown>> {
  businessObjectId: string;
  organisationId: string;
  typeKey: string;
  displayLabel: string;
  versionNo: number;
  data: TData;
  effectiveFrom: string;
  effectiveTo?: string | null;
  recordedAt: string;
  provenanceKind: ProvenanceKind;
  provenanceRef?: string | null;
}

export interface CreateBusinessObjectInput<TData extends Record<string, unknown> = Record<string, unknown>> {
  organisationId: string;
  typeKey: string;
  displayLabel: string;
  data: TData;
  effectiveFrom?: string;
  ownerActorId?: string;
  classificationKey?: string;
  provenanceKind?: ProvenanceKind;
  provenanceRef?: string;
  changeReason?: string;
  actorId?: string;
}
