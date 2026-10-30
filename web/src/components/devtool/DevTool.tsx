import React, { useCallback, useEffect, useMemo, useState } from "react";
import { useNuiEvent } from "@/hooks/useNuiEvent";
import { fetchNui } from "@/utils/fetchNui";
import { debugData } from "@/utils/debugData";

debugData<DevMessage>([
	{
		action: "koja-lib:nui:devtool",
		data: {
			action: "open",
			data: {
				coords: { x: 441.82, y: -982.05, z: 30.69 },
				heading: 92.4,
				street: "Atlee St",
				crossing: "Sinner St",
				zone: "Mission Row",
				interior: 137473,
				time: "14:32",
				noclip: false,
				overlay: true,
				frozenTime: false,
				vehicle: { model: "police3", plate: "LSPD 042", speed: 0, engine: 1000, body: 998, fuel: 87 },
			},
		},
	},
]);

interface Vec3 {
	x: number;
	y: number;
	z: number;
}

interface VehicleState {
	model: string;
	plate: string;
	speed: number;
	engine: number;
	body: number;
	fuel: number | false;
}

interface DevState {
	coords: Vec3;
	heading: number;
	street?: string;
	crossing?: string;
	zone?: string;
	interior: number;
	time: string;
	noclip: boolean;
	overlay: boolean;
	frozenTime: boolean;
	vehicle?: VehicleState | null;
}

interface Inspected {
	kind: string;
	model?: string | null;
	hash?: number;
	hashHex?: string;
	coords: Vec3;
	rotation?: Vec3;
	heading?: number;
	netId?: number | null;
	plate?: string;
	health?: number;
}

interface DevMessage {
	action: "open" | "close" | "state" | "inspecting" | "inspected";
	data: unknown;
}

type Tab = "position" | "entity" | "vehicle" | "world";

const TABS: { id: Tab; label: string }[] = [
	{ id: "position", label: "Position" },
	{ id: "entity", label: "Entity" },
	{ id: "vehicle", label: "Vehicle" },
	{ id: "world", label: "World" },
];

const WEATHERS = ["EXTRASUNNY", "CLEAR", "CLOUDS", "OVERCAST", "RAIN", "THUNDER", "FOGGY", "SMOG", "SNOW", "XMAS"];

const fixed = (value: number, digits = 2) => Number(value ?? 0).toFixed(digits);

const formats = (c: Vec3, h: number) => [
	{ label: "vector3", value: `vector3(${fixed(c.x)}, ${fixed(c.y)}, ${fixed(c.z)})` },
	{ label: "vector4", value: `vector4(${fixed(c.x)}, ${fixed(c.y)}, ${fixed(c.z)}, ${fixed(h)})` },
	{ label: "vec3", value: `vec3(${fixed(c.x)}, ${fixed(c.y)}, ${fixed(c.z)})` },
	{ label: "table", value: `{ x = ${fixed(c.x)}, y = ${fixed(c.y)}, z = ${fixed(c.z)}, w = ${fixed(h)} }` },
	{ label: "json", value: JSON.stringify({ x: +fixed(c.x), y: +fixed(c.y), z: +fixed(c.z), w: +fixed(h) }) },
];

function copyText(value: string) {
	const area = document.createElement("textarea");
	area.value = value;
	area.style.position = "fixed";
	area.style.opacity = "0";
	document.body.appendChild(area);
	area.select();
	try {
		document.execCommand("copy");
	} finally {
		document.body.removeChild(area);
	}
}

const run = (action: string, payload?: Record<string, unknown>) => fetchNui("koja-lib:devtool:action", { action, payload });

const Section: React.FC<{ title: string; children: React.ReactNode }> = ({ title, children }) => (
	<section className="flex flex-col gap-[.45vw]">
		<h3 className="text-[.62vw] font-medium text-white/45">{title}</h3>
		{children}
	</section>
);

const Action: React.FC<{ label: string; onClick: () => void; active?: boolean }> = ({ label, onClick, active }) => (
	<button
		type="button"
		onClick={onClick}
		className={`h-[1.75vw] rounded-[.35vw] px-[.6vw] text-[.66vw] font-medium transition-colors focus-visible:outline focus-visible:outline-1 focus-visible:outline-white/60 ${
			active ? "bg-[#4189e5] text-white" : "bg-white/[.06] text-white/85 hover:bg-white/[.11]"
		}`}
	>
		{label}
	</button>
);

const CopyRow: React.FC<{ label: string; value: string; copied: string | null; onCopy: (key: string, value: string) => void }> = ({ label, value, copied, onCopy }) => (
	<button
		type="button"
		onClick={() => onCopy(label, value)}
		className="group flex items-center justify-between gap-[.6vw] rounded-[.35vw] px-[.55vw] py-[.4vw] text-left hover:bg-white/[.06] focus-visible:outline focus-visible:outline-1 focus-visible:outline-white/60"
	>
		<span className="w-[3.2vw] shrink-0 text-[.6vw] text-white/40">{label}</span>
		<span className="min-w-0 flex-1 truncate font-mono text-[.62vw] text-white/85">{value}</span>
		<span className="shrink-0 text-[.58vw] text-white/40 group-hover:text-white/70">{copied === label ? "Copied" : "Copy"}</span>
	</button>
);

const Field: React.FC<{ value: string; onChange: (value: string) => void; placeholder: string; className?: string }> = ({ value, onChange, placeholder, className }) => (
	<input
		value={value}
		onChange={(event) => onChange(event.target.value)}
		placeholder={placeholder}
		spellCheck={false}
		className={`h-[1.75vw] min-w-0 rounded-[.35vw] border border-white/10 bg-black/30 px-[.5vw] font-mono text-[.64vw] text-white placeholder:text-white/30 focus:border-[#4189e5] focus:outline-none ${className ?? ""}`}
	/>
);

const Stat: React.FC<{ label: string; value: React.ReactNode }> = ({ label, value }) => (
	<div className="flex items-baseline justify-between gap-[.5vw] text-[.64vw]">
		<span className="text-white/40">{label}</span>
		<span className="truncate font-mono text-white/85">{value}</span>
	</div>
);

const DevTool: React.FC = () => {
	const [open, setOpen] = useState(false);
	const [state, setState] = useState<DevState | null>(null);
	const [tab, setTab] = useState<Tab>("position");
	const [copied, setCopied] = useState<string | null>(null);
	const [inspecting, setInspecting] = useState(false);
	const [inspected, setInspected] = useState<Inspected | null>(null);
	const [target, setTarget] = useState("");
	const [model, setModel] = useState("");
	const [hour, setHour] = useState("12");

	useNuiEvent<DevMessage>("koja-lib:nui:devtool", (message) => {
		if (message.action === "open") {
			setOpen(true);
			setState(message.data as DevState);
		} else if (message.action === "close") {
			setOpen(false);
		} else if (message.action === "state") {
			setState(message.data as DevState);
		} else if (message.action === "inspecting") {
			setInspecting(message.data === true);
		} else if (message.action === "inspected") {
			setInspected(message.data as Inspected);
			setTab("entity");
		}
	});

	const close = useCallback(() => {
		setOpen(false);
		fetchNui("koja-lib:devtool:close");
	}, []);

	useEffect(() => {
		if (!open) return;
		const onKey = (event: KeyboardEvent) => {
			if (event.key === "Escape") close();
		};
		window.addEventListener("keydown", onKey);
		return () => window.removeEventListener("keydown", onKey);
	}, [open, close]);

	const onCopy = useCallback((key: string, value: string) => {
		copyText(value);
		setCopied(key);
		window.setTimeout(() => setCopied((current) => (current === key ? null : current)), 1200);
	}, []);

	const positionFormats = useMemo(() => (state ? formats(state.coords, state.heading) : []), [state]);

	const teleport = () => {
		const parts = target.match(/-?\d+(\.\d+)?/g)?.map(Number) ?? [];
		if (parts.length < 3) return;
		run("teleportCoords", { x: parts[0], y: parts[1], z: parts[2], h: parts[3] });
	};

	if (!open || !state || inspecting) return null;

	return (
		<aside className="pointer-events-auto absolute right-[1.2vw] top-1/2 flex max-h-[80vh] w-[19vw] -translate-y-1/2 flex-col overflow-hidden rounded-[.6vw] border border-white/10 bg-[#121417]/95 text-white shadow-[0_.6vw_2vw_rgba(0,0,0,.45)]">
			<header className="flex items-center justify-between border-b border-white/[.07] px-[.9vw] py-[.7vw]">
				<div className="flex flex-col">
					<span className="text-[.78vw] font-semibold">Dev tool</span>
					<span className="text-[.58vw] text-white/40">
						{state.zone ?? "Unknown"} · {state.time}
					</span>
				</div>
				<button type="button" onClick={close} className="rounded-[.3vw] px-[.45vw] py-[.2vw] text-[.62vw] text-white/50 hover:bg-white/[.07] hover:text-white">
					Close
				</button>
			</header>

			<nav className="flex gap-[.25vw] border-b border-white/[.07] px-[.6vw] py-[.45vw]">
				{TABS.map((entry) => (
					<button
						key={entry.id}
						type="button"
						onClick={() => setTab(entry.id)}
						className={`rounded-[.3vw] px-[.55vw] py-[.3vw] text-[.64vw] font-medium transition-colors ${
							tab === entry.id ? "bg-white/[.1] text-white" : "text-white/50 hover:text-white/80"
						}`}
					>
						{entry.label}
					</button>
				))}
			</nav>

			<div className="flex flex-col gap-[.9vw] overflow-y-auto px-[.9vw] py-[.8vw]">
				{tab === "position" && (
					<>
						<Section title="Current position">
							<div className="flex flex-col">
								{positionFormats.map((entry) => (
									<CopyRow key={entry.label} label={entry.label} value={entry.value} copied={copied} onCopy={onCopy} />
								))}
							</div>
							<div className="flex flex-col gap-[.2vw] px-[.55vw]">
								<Stat label="Street" value={state.crossing ? `${state.street} / ${state.crossing}` : state.street ?? "-"} />
								<Stat label="Interior" value={state.interior || "none"} />
							</div>
						</Section>
						<Section title="Move">
							<div className="flex flex-wrap gap-[.35vw]">
								<Action label="Waypoint" onClick={() => run("teleportWaypoint")} />
								<Action label={state.noclip ? "Noclip on" : "Noclip"} active={state.noclip} onClick={() => run("noclip")} />
								<Action label={state.overlay ? "Coords on screen" : "Show coords"} active={state.overlay} onClick={() => run("overlay")} />
								<Action label="Heal" onClick={() => run("heal")} />
							</div>
							<div className="flex gap-[.35vw]">
								<Field value={target} onChange={setTarget} placeholder="x, y, z, heading" className="flex-1" />
								<Action label="Go" onClick={teleport} />
							</div>
						</Section>
					</>
				)}

				{tab === "entity" && (
					<>
						<Section title="Inspector">
							<p className="text-[.62vw] leading-relaxed text-white/50">Aim at a ped, vehicle or object, press E to read it here.</p>
							<div>
								<Action label="Start inspecting" onClick={() => run("inspect")} />
							</div>
						</Section>
						{inspected && (
							<Section title={inspected.kind === "point" ? "Point" : `Last ${inspected.kind}`}>
								<div className="flex flex-col">
									{inspected.model && <CopyRow label="model" value={inspected.model} copied={copied} onCopy={onCopy} />}
									{inspected.hash !== undefined && <CopyRow label="hash" value={String(inspected.hash)} copied={copied} onCopy={onCopy} />}
									{inspected.hashHex && <CopyRow label="hex" value={inspected.hashHex} copied={copied} onCopy={onCopy} />}
									{formats(inspected.coords, inspected.heading ?? 0)
										.slice(0, 2)
										.map((entry) => (
											<CopyRow key={`e-${entry.label}`} label={entry.label} value={entry.value} copied={copied} onCopy={onCopy} />
										))}
									{inspected.rotation && (
										<CopyRow
											label="rotation"
											value={`vector3(${fixed(inspected.rotation.x)}, ${fixed(inspected.rotation.y)}, ${fixed(inspected.rotation.z)})`}
											copied={copied}
											onCopy={onCopy}
										/>
									)}
								</div>
								<div className="flex flex-col gap-[.2vw] px-[.55vw]">
									{inspected.netId ? <Stat label="Net id" value={inspected.netId} /> : null}
									{inspected.plate ? <Stat label="Plate" value={inspected.plate} /> : null}
									{inspected.health !== undefined ? <Stat label="Health" value={inspected.health} /> : null}
								</div>
							</Section>
						)}
					</>
				)}

				{tab === "vehicle" && (
					<>
						<Section title="Spawn">
							<div className="flex gap-[.35vw]">
								<Field value={model} onChange={setModel} placeholder="model, e.g. police3" className="flex-1" />
								<Action label="Spawn" onClick={() => model.trim() && run("spawnVehicle", { model: model.trim() })} />
							</div>
						</Section>
						<Section title={state.vehicle ? `${state.vehicle.model} · ${state.vehicle.plate}` : "Not in a vehicle"}>
							{state.vehicle && (
								<div className="flex flex-col gap-[.2vw] px-[.55vw]">
									<Stat label="Speed" value={`${state.vehicle.speed} km/h`} />
									<Stat label="Engine" value={state.vehicle.engine} />
									<Stat label="Body" value={state.vehicle.body} />
									<Stat label="Fuel" value={state.vehicle.fuel === false ? "-" : `${state.vehicle.fuel}%`} />
								</div>
							)}
							<div className="flex flex-wrap gap-[.35vw]">
								<Action label="Repair" onClick={() => run("repairVehicle")} />
								<Action label="Refuel" onClick={() => run("fuelVehicle")} />
								<Action label="Flip" onClick={() => run("flipVehicle")} />
								<Action label="Keys" onClick={() => run("keysVehicle")} />
								<Action label="Delete" onClick={() => run("deleteVehicle")} />
							</div>
						</Section>
					</>
				)}

				{tab === "world" && (
					<>
						<Section title="Time, only for you">
							<div className="flex gap-[.35vw]">
								<Field value={hour} onChange={setHour} placeholder="hour" className="w-[3.5vw]" />
								<Action label="Set" onClick={() => run("setTime", { hour: Number(hour) || 0 })} />
								<Action label={state.frozenTime ? "Frozen" : "Freeze"} active={state.frozenTime} onClick={() => run("freezeTime")} />
							</div>
						</Section>
						<Section title="Weather, only for you">
							<div className="flex flex-wrap gap-[.3vw]">
								{WEATHERS.map((weather) => (
									<Action key={weather} label={weather.toLowerCase()} onClick={() => run("setWeather", { weather })} />
								))}
							</div>
						</Section>
						<Section title="Area">
							<div>
								<Action label="Clear area (50 m)" onClick={() => run("clearArea")} />
							</div>
						</Section>
					</>
				)}
			</div>
		</aside>
	);
};

export default DevTool;
