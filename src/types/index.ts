export type UnitCategory = 'weight' | 'volume';

export interface UnitInfo {
    label: string;
    value: string;
    factor: number; // conversion factor to base unit (g or ml)
}

export interface GoodsItem {
    id: string;
    name: string;
    price: number | null;
    amount: number | null;
    unit: string;
}

export interface CategoryData {
    name: string;
    category: UnitCategory;
    units: UnitInfo[];
    items: GoodsItem[];
}
