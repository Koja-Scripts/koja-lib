import { useCallback, useEffect, useRef } from "react";
import { useNuiEvent } from "@/hooks/useNuiEvent";

type SoundActionType = "playSound" | "stopSound";

type SoundEventPayload = {
	type: SoundActionType;
	file?: string;
	volume?: number;
	soundId?: string;
	loop?: boolean;
};

const DEFAULT_SOUND_VOLUME = 0.5;

const normalizeVolume = (value?: number) => {
	if (typeof value !== "number" || Number.isNaN(value)) {
		return DEFAULT_SOUND_VOLUME;
	}

	return Math.min(1, Math.max(0, value));
};

const resolveAudioPath = (file: string) => `./sounds/${file}.mp3`;

const Sounds = () => {
	const activeSoundsRef = useRef<Map<string, HTMLAudioElement>>(new Map());

	const stopSound = useCallback((soundId?: string) => {
		if (!soundId) {
			return;
		}

		const existingSound = activeSoundsRef.current.get(soundId);
		if (!existingSound) {
			return;
		}

		existingSound.pause();
		existingSound.currentTime = 0;
		activeSoundsRef.current.delete(soundId);
	}, []);

	const playSound = useCallback(async (payload: SoundEventPayload) => {
		if (!payload.file) {
			return;
		}

		if (payload.soundId) {
			stopSound(payload.soundId);
		}

		const audioPath = resolveAudioPath(payload.file);
		try {
			const response = await fetch(audioPath, { method: "HEAD" });
			if (!response.ok) {
				return;
			}
		} catch {
			return;
		}

		const audio = new Audio(audioPath);
		audio.volume = normalizeVolume(payload.volume);
		audio.loop = payload.loop === true;

		if (payload.soundId) {
			activeSoundsRef.current.set(payload.soundId, audio);
		}

		audio.addEventListener("ended", () => {
			if (payload.soundId) {
				activeSoundsRef.current.delete(payload.soundId);
			}
		});

		void audio.play().catch(() => {
			if (payload.soundId) {
				activeSoundsRef.current.delete(payload.soundId);
			}
		});
	}, [stopSound]);

	useNuiEvent<SoundEventPayload>("koja-lib:nui:createSound", (payload) => {
		if (payload.type === "playSound") {
			playSound(payload);
			return;
		}

		if (payload.type === "stopSound") {
			stopSound(payload.soundId);
		}
	});

	useEffect(() => {
		return () => {
			for (const sound of activeSoundsRef.current.values()) {
				sound.pause();
				sound.currentTime = 0;
			}

			activeSoundsRef.current.clear();
		};
	}, []);

	return null;
};

export default Sounds;
