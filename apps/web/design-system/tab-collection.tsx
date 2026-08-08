"use client";

import Link from "next/link";
import { useRef } from "react";

export interface TabCollectionItem {
  id: string;
  label: string;
  count?: number;
  symbol?: string;
  href?: string;
  disabled?: boolean;
}
export interface TabCollectionProps {
  label: string;
  items: TabCollectionItem[];
  activeId: string;
  onChange?: (id: string) => void;
  compact?: boolean;
  className?: string;
}

export function TabCollection({ label, items, activeId, onChange, compact = false, className = "" }: TabCollectionProps) {
  const refs = useRef<Array<HTMLButtonElement | HTMLAnchorElement | null>>([]);

  function moveFocus(current: number, direction: 1 | -1) {
    let next = current;
    do next = (next + direction + items.length) % items.length;
    while (items[next]?.disabled && next !== current);
    refs.current[next]?.focus();
  }

  return <div className={`s-tab-collection ${compact ? "s-tab-collection--compact" : ""} ${className}`} role="tablist" aria-label={label}>
    {items.map((item, index) => {
      const active = item.id === activeId;
      const content = <>{item.symbol && <span className="s-tab-collection__symbol" aria-hidden="true">{item.symbol}</span>}<span>{item.label}</span>{item.count !== undefined && <b className="s-tab-collection__count">{item.count}</b>}</>;
      const shared = {
        className: `s-tab-collection__item ${active ? "is-active" : ""}`,
        role: "tab" as const,
        "aria-selected": active,
        tabIndex: active ? 0 : -1,
        onKeyDown: (event: React.KeyboardEvent) => {
          if (event.key === "ArrowRight") { event.preventDefault(); moveFocus(index, 1); }
          if (event.key === "ArrowLeft") { event.preventDefault(); moveFocus(index, -1); }
          if (event.key === "Home") { event.preventDefault(); refs.current[0]?.focus(); }
          if (event.key === "End") { event.preventDefault(); refs.current[items.length - 1]?.focus(); }
        },
      };
      return item.href
        ? <Link {...shared} aria-current={active ? "page" : undefined} href={item.href} key={item.id} ref={(node) => { refs.current[index] = node; }}>{content}</Link>
        : <button {...shared} disabled={item.disabled} type="button" key={item.id} ref={(node) => { refs.current[index] = node; }} onClick={() => onChange?.(item.id)}>{content}</button>;
    })}
  </div>;
}
