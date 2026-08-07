import type { GovernedRecordLink } from "@sapphire/core-types";

export interface GovernedRecordAdapter {
  supports(link: GovernedRecordLink): boolean;
  href(link: GovernedRecordLink): string;
  canCompleteActionFromRecord(): false;
}

export interface ActionsRealtimeInvalidation {
  organisationId: string;
  missionId?: string | null;
  actionItemId?: string | null;
  ownerUserId?: string | null;
}

export const workspaceRecordAdapter: GovernedRecordAdapter = {
  supports(link) {
    return ["Inbox", "Market Radar", "Opportunities", "Deals", "Governance", "Documents", "Profiles", "Finance"].includes(link.workspace);
  },
  href(link) {
    return link.href;
  },
  canCompleteActionFromRecord() {
    return false;
  },
};

export function queueKeysForInvalidation(event: ActionsRealtimeInvalidation) {
  return [
    `actions:org:${event.organisationId}`,
    event.ownerUserId ? `actions:owner:${event.ownerUserId}` : null,
    event.missionId ? `actions:mission:${event.missionId}` : null,
    event.actionItemId ? `actions:item:${event.actionItemId}` : null,
  ].filter((key): key is string => Boolean(key));
}
