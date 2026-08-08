import type { Metadata } from "next";
import { ActionsWorkspace } from "../../components/actions/actions-workspace";
import { actionsFixture } from "../../components/actions/actions-fixture";

export const metadata: Metadata = {
  title: "Actions | Sapphire Core OS",
  description: "Accountable commercial execution, Action Context and governed Work Journal.",
};

export default function ActionsPage() {
  return <ActionsWorkspace initialSnapshot={actionsFixture} />;
}
