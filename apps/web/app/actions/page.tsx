import { ActionsWorkspace } from "../../components/actions/actions-workspace";
import { actionsFixture } from "../../components/actions/actions-fixture";

export default function ActionsPage() {
  return <ActionsWorkspace initialSnapshot={actionsFixture} />;
}
