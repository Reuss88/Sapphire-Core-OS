"use client";

import Link from "next/link";
import type { ReactNode } from "react";
import { useEffect, useRef, useState } from "react";
import { IconButton } from "./primitives";

export const SAPPHIRE_NAV_PIN_STORAGE_KEY = "sapphire.shell.nav-pinned.v1";

export interface WorkspaceNavigationItem {
  label: string;
  href: string;
  symbol: string;
}
export const workspaceNavigation: WorkspaceNavigationItem[] = [
  { label: "Home", href: "/dashboard", symbol: "◇" },
  { label: "Actions", href: "/actions", symbol: "◆" },
  { label: "Inbox", href: "/inbox", symbol: "◇" },
  { label: "Market Radar", href: "/market-radar", symbol: "◇" },
  { label: "Demand", href: "/demand", symbol: "◇" },
  { label: "Supply", href: "/supply", symbol: "◇" },
  { label: "Opportunities", href: "/opportunities", symbol: "◇" },
  { label: "Matching", href: "/matching", symbol: "◇" },
  { label: "Deals", href: "/deals", symbol: "◇" },
  { label: "Network", href: "/network", symbol: "◇" },
  { label: "Profiles", href: "/profiles", symbol: "◇" },
  { label: "Intelligence", href: "/intelligence", symbol: "◇" },
  { label: "Documents", href: "/documents", symbol: "◇" },
  { label: "Finance", href: "/finance", symbol: "◇" },
  { label: "Governance", href: "/governance", symbol: "◇" },
];

export interface SapphireShellProps {
  activeWorkspace: string;
  eyebrow: string;
  title: string;
  commands?: ReactNode;
  identity?: ReactNode;
  footer?: ReactNode;
  className?: string;
  children: ReactNode;
}

export function SapphireShell({ activeWorkspace, eyebrow, title, commands, identity, footer, className = "", children }: SapphireShellProps) {
  const [navHovered, setNavHovered] = useState(false);
  const [navPinned, setNavPinned] = useState(false);
  const [mobileNavOpen, setMobileNavOpen] = useState(false);
  const navCloseTimer = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    const frame = window.requestAnimationFrame(() => {
      try { setNavPinned(window.sessionStorage.getItem(SAPPHIRE_NAV_PIN_STORAGE_KEY) === "true"); } catch { /* optional presentation state */ }
    });
    return () => window.cancelAnimationFrame(frame);
  }, []);

  function revealNav() {
    if (navCloseTimer.current) clearTimeout(navCloseTimer.current);
    setNavHovered(true);
  }

  function scheduleNavClose() {
    if (navCloseTimer.current) clearTimeout(navCloseTimer.current);
    navCloseTimer.current = setTimeout(() => setNavHovered(false), 180);
  }

  function toggleNavPin() {
    const next = !navPinned;
    setNavPinned(next);
    try { window.sessionStorage.setItem(SAPPHIRE_NAV_PIN_STORAGE_KEY, String(next)); } catch { /* optional presentation state */ }
  }

  const navExpanded = navHovered || navPinned || mobileNavOpen;

  return <main className={`sapphire-app ${className}`}>
    <aside className="brand-rail" aria-label="Sapphire workspaces" data-expanded={navExpanded} data-mobile-open={mobileNavOpen} onMouseEnter={revealNav} onMouseLeave={scheduleNavClose} onFocus={revealNav} onBlur={(event) => { if (!event.currentTarget.contains(event.relatedTarget)) scheduleNavClose(); }}>
      <div className="nav-brand-row"><Link className="brand" href="/dashboard" aria-label="Sapphire Core OS home"><span className="brand-mark">◇</span><span>SAPPHIRE<small>CORE OS</small></span></Link><IconButton className="nav-pin" label={navPinned ? "Unpin workspace navigation" : "Pin workspace navigation"} aria-pressed={navPinned} onClick={toggleNavPin}>{navPinned ? "●" : "○"}</IconButton><IconButton className="nav-mobile-close" label="Close workspace navigation" onClick={() => setMobileNavOpen(false)}>×</IconButton></div>
      <nav className="workspace-nav" aria-label="Primary workspaces">{workspaceNavigation.map((item) => <Link key={item.label} href={item.href} className={item.label === activeWorkspace ? "active" : ""} aria-current={item.label === activeWorkspace ? "page" : undefined}><span aria-hidden="true">{item.symbol}</span><b>{item.label}</b></Link>)}</nav>
      <div className="system-state"><span /> <b>All systems operational</b></div>
    </aside>
    {mobileNavOpen && <button type="button" className="nav-scrim" aria-label="Close workspace navigation" onClick={() => setMobileNavOpen(false)} />}

    <section className="workspace-shell">
      <header className="command-header">
        <div className="command-title"><IconButton className="mobile-menu-button" label="Open workspace navigation" onClick={() => setMobileNavOpen(true)}>☰</IconButton><div><p className="eyebrow">{eyebrow}</p><h1>{title}</h1></div></div>
        <div className="command-actions">{commands}{identity}</div>
      </header>
      {children}
      {footer}
    </section>
  </main>;
}

export function DirectorIdentity({ name = "Reuss", role = "Director", initials = "R" }: { name?: string; role?: string; initials?: string }) {
  return <div className="director-chip"><span>{initials}</span><div><strong>{name}</strong><small>{role}</small></div></div>;
}
