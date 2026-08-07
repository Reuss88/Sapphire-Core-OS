import type { MetadataRoute } from "next";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "Sapphire Core OS",
    short_name: "Sapphire",
    description: "Accountable commercial execution for Sapphire Core OS.",
    start_url: "/actions",
    display: "standalone",
    background_color: "#090c14",
    theme_color: "#090c14",
  };
}
