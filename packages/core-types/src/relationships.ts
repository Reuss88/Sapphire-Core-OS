import type { ArchitectureStatus, ProvenanceKind } from "./business-objects";

export type RelationshipDirection = "directed" | "undirected" | "reciprocal";

export type RelationshipCardinality =
  | "one_to_one"
  | "one_to_many"
  | "many_to_one"
  | "many_to_many";

export interface RelationshipTypeDefinition {
  id: string;
  typeKey: string;
  canonicalName: string;
  description: string;
  relationshipFamily: string;
  sourceObjectTypeId: string;
  targetObjectTypeId: string;
  directionality: RelationshipDirection;
  inverseName?: string | null;
  sourceRole: string;
  targetRole: string;
  cardinality: RelationshipCardinality;
  minSourceParticipation: number;
  maxSourceParticipation?: number | null;
  minTargetParticipation: number;
  maxTargetParticipation?: number | null;
  isExclusive: boolean;
  isSymmetric: boolean;
  isTransitive: boolean;
  allowsSelfReference: boolean;
  compositionSemantics: boolean;
  aggregationSemantics: boolean;
  dependencySemantics: Record<string, unknown>;
  validityRules: Record<string, unknown>;
  ownershipModel: Record<string, unknown>;
  provenanceRequirements: Record<string, unknown>;
  evidenceRequirements: Record<string, unknown>;
  lifecyclePolicy: Record<string, unknown>;
  versioningPolicy: Record<string, unknown>;
  implementationMappings: Record<string, unknown>;
  architectureStatus: ArchitectureStatus;
  architectureVersion: string;
  effectiveFrom?: string | null;
  effectiveTo?: string | null;
}

export interface RelationshipIdentity {
  id: string;
  organisationId: string;
  relationshipTypeId: string;
  sourceBusinessObjectId: string;
  targetBusinessObjectId: string;
  currentVersionNo: number;
  isActive: boolean;
  createdAt: string;
  createdBy?: string | null;
  retiredAt?: string | null;
  retiredBy?: string | null;
}

export interface RelationshipVersion<TData extends Record<string, unknown> = Record<string, unknown>> {
  id: string;
  relationshipId: string;
  versionNo: number;
  sourceRole: string;
  targetRole: string;
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

export interface RelationshipParticipant {
  id: string;
  relationshipId: string;
  businessObjectId: string;
  participantRole: string;
  ordinal?: number | null;
  effectiveFrom: string;
  effectiveTo?: string | null;
  recordedAt: string;
  recordedBy?: string | null;
  provenanceKind: ProvenanceKind;
  provenanceRef?: string | null;
}

export interface RelationshipIdentifier {
  id: string;
  relationshipId: string;
  namespace: string;
  identifierValue: string;
  sourceSystem?: string | null;
  isPrimary: boolean;
  effectiveFrom: string;
  effectiveTo?: string | null;
  recordedAt: string;
  recordedBy?: string | null;
}

export interface RelationshipSnapshot<TData extends Record<string, unknown> = Record<string, unknown>> {
  relationshipId: string;
  organisationId: string;
  typeKey: string;
  sourceBusinessObjectId: string;
  targetBusinessObjectId: string;
  sourceRole: string;
  targetRole: string;
  versionNo: number;
  data: TData;
  effectiveFrom: string;
  effectiveTo?: string | null;
  recordedAt: string;
  provenanceKind: ProvenanceKind;
  provenanceRef?: string | null;
  isActive: boolean;
}

export interface CreateRelationshipInput<TData extends Record<string, unknown> = Record<string, unknown>> {
  organisationId: string;
  relationshipTypeKey: string;
  sourceBusinessObjectId: string;
  targetBusinessObjectId: string;
  data?: TData;
  effectiveFrom?: string;
  provenanceKind?: ProvenanceKind;
  provenanceRef?: string;
  changeReason?: string;
  actorId?: string;
}

export interface AddRelationshipVersionInput<TData extends Record<string, unknown> = Record<string, unknown>> {
  relationshipId: string;
  data: TData;
  effectiveFrom?: string;
  provenanceKind?: ProvenanceKind;
  provenanceRef?: string;
  changeReason?: string;
  actorId?: string;
}

export interface RetireRelationshipInput {
  relationshipId: string;
  retiredAt?: string;
  reason?: string;
  actorId?: string;
}
