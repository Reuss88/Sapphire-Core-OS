"use client";

import Link from "next/link";
import type { FocusEvent, MouseEventHandler, ReactNode } from "react";
import { useEffect, useRef, useState } from "react";
import { IconButton, Input } from "./primitives";
import { workspaceNavigation } from "./workspace-registry";

export { workspaceNavigation } from "./workspace-registry";
export type { WorkspaceNavigationItem } from "./workspace-registry";

export const SAPPHIRE_NAV_PIN_STORAGE_KEY = "sapphire.shell.nav-pinned.v1";

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

export function NavigationPanel({ activeWorkspace, onNavigate }: { activeWorkspace: string; onNavigate?: () => void }) {
  return <nav className="workspace-nav" aria-label="Primary workspaces">{workspaceNavigation.map((item) => <Link key={item.label} href={item.href} onClick={onNavigate} className={item.label === activeWorkspace ? "active" : ""} aria-current={item.label === activeWorkspace ? "page" : undefined}><span aria-hidden="true">{item.symbol}</span><b>{item.label}</b></Link>)}</nav>;
}

export interface WorkspaceRailProps {
  activeWorkspace: string;
  expanded: boolean;
  mobileOpen: boolean;
  pinned: boolean;
  onPin: () => void;
  onMobileClose: () => void;
  onMouseEnter: MouseEventHandler<HTMLElement>;
  onMouseLeave: MouseEventHandler<HTMLElement>;
  onFocus: () => void;
  onBlur: (event: FocusEvent<HTMLElement>) => void;
}

export function WorkspaceRail({ activeWorkspace, expanded, mobileOpen, pinned, onPin, onMobileClose, ...events }: WorkspaceRailProps) {
  return <aside className="brand-rail" aria-label="Sapphire workspaces" data-expanded={expanded} data-mobile-open={mobileOpen} {...events}><div className="nav-brand-row"><Link className="brand" href="/dashboard" aria-label="Sapphire Core OS home"><span className="brand-mark">◇</span><span>SAPPHIRE<small>CORE OS</small></span></Link><IconButton className="nav-pin" label={pinned ? "Unpin workspace navigation" : "Pin workspace navigation"} aria-pressed={pinned} onClick={onPin}>{pinned ? "●" : "○"}</IconButton><IconButton className="nav-mobile-close" label="Close workspace navigation" onClick={onMobileClose}>×</IconButton></div><NavigationPanel activeWorkspace={activeWorkspace} onNavigate={onMobileClose} /><div className="system-state"><span /> <b>All systems operational</b></div></aside>;
}

export function CommandHeader({ eyebrow, title, commands, identity, onMenuOpen }: { eyebrow: string; title: string; commands?: ReactNode; identity?: ReactNode; onMenuOpen: () => void }) {
  return <header className="command-header"><div className="command-title"><IconButton className="mobile-menu-button" label="Open workspace navigation" onClick={onMenuOpen}>☰</IconButton><div><p className="eyebrow">{eyebrow}</p><h1>{title}</h1></div></div><div className="command-actions">{commands}{identity}</div></header>;
}

export function GlobalSearch({ label = "Search Sapphire Core OS", placeholder = "Search workspaces, records and people…" }: { label?: string; placeholder?: string }) {
  return <label className="s-global-search"><span aria-hidden="true">⌕</span><span className="s-visually-hidden">{label}</span><Input type="search" placeholder={placeholder} /></label>;
}

export function WorkspaceFooter({ children }: { children: ReactNode }) {
  return <footer className="workspace-footer">{children}</footer>;
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
    <WorkspaceRail activeWorkspace={activeWorkspace} expanded={navExpanded} mobileOpen={mobileNavOpen} pinned={navPinned} onPin={toggleNavPin} onMobileClose={() => setMobileNavOpen(false)} onMouseEnter={revealNav} onMouseLeave={scheduleNavClose} onFocus={revealNav} onBlur={(event) => { if (!event.currentTarget.contains(event.relatedTarget)) scheduleNavClose(); }} />
    {mobileNavOpen && <button type="button" className="nav-scrim" aria-label="Close workspace navigation" onClick={() => setMobileNavOpen(false)} />}

    <section className="workspace-shell">
      <CommandHeader eyebrow={eyebrow} title={title} commands={commands} identity={identity} onMenuOpen={() => setMobileNavOpen(true)} />
      {children}
      {footer}
    </section>
  </main>;
}

export function DirectorIdentity({ name = "Reuss", role = "Director", initials = "R" }: { name?: string; role?: string; initials?: string }) {
  return <div className="director-chip"><span>{initials}</span><div><strong>{name}</strong><small>{role}</small></div></div>;
}
