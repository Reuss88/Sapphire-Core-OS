import type { Metadata, Viewport } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Actions | Sapphire Core OS",
  description: "Accountable commercial execution for Sapphire Core OS.",
  manifest: "/manifest.webmanifest",
  applicationName: "Sapphire Core OS",
};

export const viewport: Viewport = {
  themeColor: "#090c14",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
