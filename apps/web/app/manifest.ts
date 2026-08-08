import type { MetadataRoute } from "next";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "Sapphire Core OS",
    short_name: "Sapphire",
    description: "Director command, accountable commercial execution and governed intelligence.",
    start_url: "/dashboard",
    display: "standalone",
    background_color: "#090c14",
    theme_color: "#090c14",
  };
}
