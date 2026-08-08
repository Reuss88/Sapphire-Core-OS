import { Card, CardBody, CardHeader, DirectorIdentity, Eyebrow, LinkButton, SapphireShell, StatusBadge } from ".";
import type { WorkspaceNavigationItem } from "./workspace-registry";

export function WorkspacePlaceholder({ workspace, detail }: { workspace: WorkspaceNavigationItem; detail: string[] }) {
  const requestedRecord = detail.length ? `Requested record path: /${detail.join("/")}` : "No record was requested.";
  return <SapphireShell className="s-placeholder-app" activeWorkspace={workspace.label} eyebrow="GOVERNED WORKSPACE" title={workspace.label} identity={<DirectorIdentity />}>
    <Card variant="focus" chrome="reverse" headerGradient className="s-workspace-placeholder">
      <CardHeader><div><Eyebrow>{workspace.owner}</Eyebrow><h2>{workspace.label} is not yet available</h2></div><StatusBadge tone="warning">planned</StatusBadge></CardHeader>
      <CardBody>
        <p>{workspace.description}</p>
        <p>This route is reserved inside Sapphire Core OS. No substitute data, unrelated redirect or false implementation has been presented.</p>
        <small>{requestedRecord}</small>
        <div className="s-button-group"><LinkButton href="/dashboard" variant="primary">Return Home</LinkButton><LinkButton href="/actions">Open Actions</LinkButton></div>
      </CardBody>
    </Card>
  </SapphireShell>;
}
