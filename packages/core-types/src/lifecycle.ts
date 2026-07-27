// Canonical TypeScript contracts for Lifecycle Foundation

export interface LifecycleStateDefinition {
  id: string;
  lifecycleDefinitionVersionId: string;
  key: string;
  name: string;
  description?: string | null;
  isTerminal: boolean;
  position: number;
}

export interface LifecycleTransitionDefinition {
  id: string;
  lifecycleDefinitionVersionId: string;
  key: string;
  fromStateKey: string;
  toStateKey: string;
  guardExpression?: string | null;
  description?: string | null;
  isReversible: boolean;
  position: number;
}

export interface LifecycleDefinition {
  id: string;
  typeKey: string;
  canonicalName: string;
  description: string;
  currentPublishedVersionId?: string | null;
  createdAt: string;
  createdBy?: string | null;
  updatedAt: string;
  updatedBy?: string | null;
}

export interface LifecycleDefinitionVersion {
  id: string;
  lifecycleDefinitionId: string;
  versionNo: number;
  name: string;
  description: string;
  effectiveFrom: string;
  published: boolean;
  recordedAt: string;
  recordedBy?: string | null;
}

export interface LifecycleApplicability {
  id: string;
  lifecycleDefinitionId: string;
  organisationId?: string | null;
  objectFamily?: string | null;
  objectType?: string | null;
  createdAt: string;
  createdBy?: string | null;
}

export interface LifecycleInstance {
  id: string;
  organisationId: string;
  objectType: string;
  objectId: string;
  lifecycleDefinitionVersionId: string;
  currentStateKey: string;
  currentStateInstanceId?: string | null;
  isRetired: boolean;
  createdAt: string;
  createdBy?: string | null;
  updatedAt: string;
  updatedBy?: string | null;
}

export interface LifecycleStateInstance {
  id: string;
  lifecycleInstanceId: string;
  stateKey: string;
  effectiveFrom: string;
  effectiveTo?: string | null;
  recordedAt: string;
  recordedBy?: string | null;
}

export interface LifecycleTransitionRequest {
  id: string;
  requestId?: string | null; // idempotency token
  lifecycleInstanceId: string;
  requestedTransitionKey: string;
  requestedBy?: string | null;
  requestedAt: string;
  desiredEffectiveFrom?: string | null;
  expectedCurrentStateInstanceId?: string | null;
  status: 'pending' | 'withdrawn' | 'executed' | 'rejected';
  resultReason?: string | null;
  processedAt?: string | null;
}

export interface LifecycleTransitionEvaluation {
  id: string;
  transitionRequestId: string;
  evaluatorId?: string | null;
  evaluatedAt: string;
  approved: boolean;
  reason?: string | null;
  evaluationData?: Record<string, unknown> | null;
}

export interface LifecycleTransitionEvent {
  id: string;
  transitionRequestId: string;
  lifecycleInstanceId: string;
  fromStateKey?: string | null;
  toStateKey: string;
  executedBy?: string | null;
  executedAt: string;
  effectiveFrom: string;
  eventData?: Record<string, unknown> | null;
}

export interface LifecycleAuditEvent {
  id: string;
  organisationId?: string | null;
  lifecycleInstanceId?: string | null;
  eventType: string;
  actorId?: string | null;
  occurredAt: string;
  eventData: Record<string, unknown>;
}
