import AsyncStorage from "@react-native-async-storage/async-storage";

const STORAGE_KEY = "saved_parkings";

interface SavedParking {
  id: string;
  rules: unknown;
  imageUri: string | null;
  savedAt: string;
}

export async function saveParking(rules: unknown, imageUri: string | null): Promise<void> {
  const existing = await getSavedParkings();
  const entry: SavedParking = {
    id: Date.now().toString(),
    rules,
    imageUri,
    savedAt: new Date().toISOString(),
  };
  existing.unshift(entry);
  await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(existing));
}

export async function getSavedParkings(): Promise<SavedParking[]> {
  const raw = await AsyncStorage.getItem(STORAGE_KEY);
  if (!raw) return [];
  try {
    return JSON.parse(raw) as SavedParking[];
  } catch {
    return [];
  }
}

export async function getSavedCount(): Promise<number> {
  const parkings = await getSavedParkings();
  return parkings.length;
}
