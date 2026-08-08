"use client";

import type { HTMLAttributes, ReactNode, RefObject } from "react";
import { useEffect, useId, useRef } from "react";
import { IconButton } from "./primitives";

function cx(...values: Array<string | false | null | undefined>) {
  return values.filter(Boolean).join(" ");
}

export interface DialogProps {
  open: boolean;
  title: string;
  eyebrow?: string;
  description?: string;
  onClose: () => void;
  children: ReactNode;
  footer?: ReactNode;
  className?: string;
  irreversible?: boolean;
  returnFocusRef?: RefObject<HTMLElement | null>;
}

export function Dialog({ open, title, eyebrow, description, onClose, children, footer, className, irreversible = false, returnFocusRef }: DialogProps) {
  const titleId = useId();
  const descriptionId = useId();
  const panelRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!open) return;
    const previous = returnFocusRef?.current ?? document.activeElement as HTMLElement | null;
    const overflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    const frame = requestAnimationFrame(() => {
      const panel = panelRef.current;
      (panel?.querySelector<HTMLElement>("[autofocus]") ?? panel?.querySelector<HTMLElement>("input, select, textarea") ?? panel?.querySelector<HTMLElement>("button"))?.focus();
    });
    function onKeyDown(event: KeyboardEvent) {
      if (event.key === "Escape" && !irreversible) onClose();
      if (event.key !== "Tab" || !panelRef.current) return;
      const focusable = [...panelRef.current.querySelectorAll<HTMLElement>('button:not([disabled]), [href], input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])')];
      if (focusable.length === 0) return;
      const first = focusable[0];
      const last = focusable[focusable.length - 1];
      if (event.shiftKey && document.activeElement === first) { event.preventDefault(); last.focus(); }
      if (!event.shiftKey && document.activeElement === last) { event.preventDefault(); first.focus(); }
    }
    document.addEventListener("keydown", onKeyDown);
    return () => { cancelAnimationFrame(frame); document.removeEventListener("keydown", onKeyDown); document.body.style.overflow = overflow; requestAnimationFrame(() => previous?.focus()); };
  }, [irreversible, onClose, open, returnFocusRef]);

  if (!open) return null;
  return <div className="s-overlay" role="presentation" onMouseDown={(event) => { if (event.target === event.currentTarget && !irreversible) onClose(); }}><div ref={panelRef} className={cx("s-dialog", irreversible && "s-dialog--irreversible", className)} role="dialog" aria-modal="true" aria-labelledby={titleId} aria-describedby={description ? descriptionId : undefined}><header className="s-dialog__header"><div>{eyebrow && <p className="s-eyebrow">{eyebrow}</p>}<h2 id={titleId}>{title}</h2>{description && <p id={descriptionId}>{description}</p>}</div>{!irreversible && <IconButton label={`Close ${title}`} onClick={onClose}>×</IconButton>}</header><div className="s-dialog__body">{children}</div>{footer && <footer className="s-dialog__footer">{footer}</footer>}</div></div>;
}

export function Drawer({ open, title, onClose, children, side = "right" }: { open: boolean; title: string; onClose: () => void; children: ReactNode; side?: "left" | "right" }) {
  const titleId = useId();
  if (!open) return null;
  return <div className="s-overlay" role="presentation" onMouseDown={(event) => { if (event.target === event.currentTarget) onClose(); }}><aside className={`s-drawer s-drawer--${side}`} role="dialog" aria-modal="true" aria-labelledby={titleId}><header><h2 id={titleId}>{title}</h2><IconButton label={`Close ${title}`} onClick={onClose}>×</IconButton></header><div>{children}</div></aside></div>;
}

export function Popover({ open, label, children, className }: { open: boolean; label: string; children: ReactNode; className?: string }) {
  if (!open) return null;
  return <div className={cx("s-popover", className)} role="dialog" aria-label={label}>{children}</div>;
}

export function Tooltip({ label, children }: { label: string; children: ReactNode }) {
  return <span className="s-tooltip" data-tooltip={label}>{children}</span>;
}

export function Toast({ tone = "info", title, detail, onDismiss }: { tone?: "info" | "success" | "warning" | "critical"; title: string; detail?: string; onDismiss?: () => void }) {
  return <div className={`s-toast s-toast--${tone}`} role={tone === "critical" ? "alert" : "status"}><span aria-hidden="true">{tone === "success" ? "✓" : tone === "critical" ? "!" : "◇"}</span><div><strong>{title}</strong>{detail && <p>{detail}</p>}</div>{onDismiss && <IconButton label={`Dismiss ${title}`} onClick={onDismiss}>×</IconButton>}</div>;
}

export function CommandPaletteFrame({ children, className, ...props }: HTMLAttributes<HTMLDivElement>) {
  return <div className={cx("s-command-palette", className)} role="search" {...props}>{children}</div>;
}
