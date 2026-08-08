import type { Metadata, Viewport } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Sapphire Core OS",
  description: "Director command, accountable commercial execution and governed intelligence.",
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
