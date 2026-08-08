import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { WorkspacePlaceholder } from "../../../design-system/workspace-placeholder";
import { placeholderWorkspaces } from "../../../design-system/workspace-registry";

interface WorkspaceRouteProps {
  params: Promise<{ workspace: string; detail?: string[] }>;
}

export async function generateMetadata({ params }: WorkspaceRouteProps): Promise<Metadata> {
  const { workspace: slug } = await params;
  const workspace = placeholderWorkspaces.get(slug);
  return workspace ? { title: `${workspace.label} | Sapphire Core OS`, description: workspace.description } : {};
}

export default async function ReservedWorkspacePage({ params }: WorkspaceRouteProps) {
  const { workspace: slug, detail = [] } = await params;
  const workspace = placeholderWorkspaces.get(slug);
  if (!workspace) notFound();
  return <WorkspacePlaceholder workspace={workspace} detail={detail} />;
}
