export interface LifecycleState {
  key: string;
  name: string;
  description?: string | null;
  isTerminal?: boolean;
}

export interface LifecycleTransition {
  from: string;
  to: string;
  guard?: string | null;
  reason?: string | null;
}

export interface LifecycleDefinition {
  id: string;
  typeKey: string;
  canonicalName: string;
  description: string;
  states: LifecycleState[];
  transitions: LifecycleTransition[];
  createdAt: string;
  updatedAt: string;
}
