import type { Metadata } from "next";
import { HomeDashboard } from "./home-dashboard";

export const metadata: Metadata = {
  title: "Sapphire Core OS — HOME",
  description: "Director commercial command deck prototype",
};

export default function Home() {
  return <HomeDashboard />;
}
