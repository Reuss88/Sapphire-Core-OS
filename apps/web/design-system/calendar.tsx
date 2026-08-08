"use client";

import { useMemo, useRef, useState } from "react";
import type { KeyboardEvent } from "react";
import { Button } from "./primitives";

const weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

export function Calendar({ initialDate = new Date(2026, 7, 8), onSelect, locale = "en-GB", timeZone = "Europe/London" }: { initialDate?: Date; onSelect?: (date: Date) => void; locale?: string; timeZone?: string }) {
  const [visibleMonth, setVisibleMonth] = useState(new Date(initialDate.getFullYear(), initialDate.getMonth(), 1));
  const [selected, setSelected] = useState(initialDate);
  const gridRef = useRef<HTMLDivElement>(null);
  const days = useMemo(() => {
    const firstOffset = (visibleMonth.getDay() + 6) % 7;
    const count = new Date(visibleMonth.getFullYear(), visibleMonth.getMonth() + 1, 0).getDate();
    return [...Array(firstOffset).fill(null), ...Array.from({ length: count }, (_, index) => new Date(visibleMonth.getFullYear(), visibleMonth.getMonth(), index + 1))];
  }, [visibleMonth]);

  function choose(date: Date) {
    setSelected(date);
    onSelect?.(date);
  }

  function moveSelection(offset: number) {
    const next = new Date(selected.getFullYear(), selected.getMonth(), selected.getDate() + offset);
    choose(next);
    if (next.getMonth() !== visibleMonth.getMonth() || next.getFullYear() !== visibleMonth.getFullYear()) setVisibleMonth(new Date(next.getFullYear(), next.getMonth(), 1));
    requestAnimationFrame(() => gridRef.current?.querySelector<HTMLElement>(`[data-date="${next.toISOString().slice(0, 10)}"]`)?.focus());
  }

  function onGridKeyDown(event: KeyboardEvent<HTMLDivElement>) {
    const offsets: Record<string, number> = { ArrowLeft: -1, ArrowRight: 1, ArrowUp: -7, ArrowDown: 7 };
    if (event.key in offsets) { event.preventDefault(); moveSelection(offsets[event.key]); }
    if (event.key === "Home") { event.preventDefault(); moveSelection(-((selected.getDay() + 6) % 7)); }
    if (event.key === "End") { event.preventDefault(); moveSelection(6 - ((selected.getDay() + 6) % 7)); }
  }

  return <div className="s-calendar" aria-label="Calendar">
    <div className="s-calendar__header"><Button size="compact" variant="quiet" aria-label="Previous month" onClick={() => setVisibleMonth(new Date(visibleMonth.getFullYear(), visibleMonth.getMonth() - 1, 1))}>←</Button><strong aria-live="polite">{visibleMonth.toLocaleDateString(locale, { month: "long", year: "numeric" })}</strong><Button size="compact" variant="quiet" aria-label="Next month" onClick={() => setVisibleMonth(new Date(visibleMonth.getFullYear(), visibleMonth.getMonth() + 1, 1))}>→</Button></div>
    <div ref={gridRef} className="s-calendar__grid" role="grid" onKeyDown={onGridKeyDown}><div className="s-calendar__weekdays" role="row">{weekdays.map((day) => <span role="columnheader" key={day}>{day}</span>)}</div><div className="s-calendar__days" role="row">{days.map((date, index) => date ? <button type="button" role="gridcell" data-date={date.toISOString().slice(0, 10)} aria-label={date.toLocaleDateString(locale, { day: "numeric", month: "long", year: "numeric" })} aria-selected={date.toDateString() === selected.toDateString()} tabIndex={date.toDateString() === selected.toDateString() ? 0 : -1} className={date.toDateString() === selected.toDateString() ? "is-selected" : ""} key={date.toISOString()} onClick={() => choose(date)}>{date.getDate()}</button> : <span aria-hidden="true" key={`empty-${index}`} />)}</div></div>
    <p className="s-calendar__timezone">Times shown in {timeZone}</p>
  </div>;
}

export interface AgendaItem {
  id: string;
  at: string;
  title: string;
  context?: string;
  tone?: "neutral" | "warning" | "critical";
}

export function Agenda({ items, timeZone = "Europe/London" }: { items: AgendaItem[]; timeZone?: string }) {
  return <section className="s-agenda" aria-label={`Agenda, ${timeZone}`}><header><strong>Agenda</strong><span>{timeZone}</span></header>{items.length ? <ol>{items.map((item) => <li className={`s-agenda__item s-agenda__item--${item.tone ?? "neutral"}`} key={item.id}><time dateTime={item.at}>{new Intl.DateTimeFormat("en-GB", { hour: "2-digit", minute: "2-digit", hour12: false, timeZone }).format(new Date(item.at))}</time><span><strong>{item.title}</strong>{item.context && <small>{item.context}</small>}</span></li>)}</ol> : <p>No scheduled work in this period.</p>}</section>;
}
