import type { CategoryData, GoodsItem } from '../types';

// 每个分类默认生成的商品数量
export const DEFAULT_ITEMS_COUNT = 2;

// 生成唯一 ID 的辅助函数
export const generateId = (): string => {
    if (typeof crypto !== 'undefined' && crypto.randomUUID) {
        return crypto.randomUUID();
    }
    return Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
};

// 为指定分类创建默认商品列表
export const createDefaultItems = (defaultUnit: string, count: number = DEFAULT_ITEMS_COUNT): GoodsItem[] => {
    return Array.from({ length: count }, () => ({
        id: generateId(),
        name: '',
        price: null,
        amount: null,
        unit: defaultUnit,
    }));
};

export const INITIAL_CATEGORIES: Omit<CategoryData, 'items'>[] = [
    {
        name: 'category.weight',
        category: 'weight',
        units: [
            { label: 'unit.g', value: 'g', factor: 1 },
            { label: 'unit.kg', value: 'kg', factor: 1000 },
            { label: 'unit.jin', value: 'jin', factor: 500 },
            { label: 'unit.liang', value: 'liang', factor: 50 },
            { label: 'unit.lb', value: 'lb', factor: 453.592 },
            { label: 'unit.oz', value: 'oz', factor: 28.3495 },
        ],
        defaultUnit: 'g',
    },
    {
        name: 'category.volume',
        category: 'volume',
        units: [
            { label: 'unit.ml', value: 'ml', factor: 1 },
            { label: 'unit.l', value: 'l', factor: 1000 },
            { label: 'unit.m3', value: 'm3', factor: 1000000 },
            { label: 'unit.cm3', value: 'cm3', factor: 1 },
            { label: 'unit.fl_oz', value: 'fl_oz', factor: 29.5735 },
            { label: 'unit.pt', value: 'pt', factor: 473.176 },
            { label: 'unit.gal', value: 'gal', factor: 3785.41 },
        ],
        defaultUnit: 'ml',
    },
    {
        name: 'category.length',
        category: 'length',
        units: [
            { label: 'unit.m', value: 'm', factor: 100 },
            { label: 'unit.cm', value: 'cm', factor: 1 },
            { label: 'unit.mm', value: 'mm', factor: 0.1 },
            { label: 'unit.yd', value: 'yd', factor: 91.44 },
            { label: 'unit.ft', value: 'ft', factor: 30.48 },
        ],
        defaultUnit: 'm',
    },
    {
        name: 'category.area',
        category: 'area',
        units: [
            { label: 'unit.m2', value: 'm2', factor: 1 },
            { label: 'unit.sq_ft', value: 'sq_ft', factor: 0.092903 },
            { label: 'unit.mu', value: 'mu', factor: 666.667 },
            { label: 'unit.ha', value: 'ha', factor: 10000 },
        ],
        defaultUnit: 'm2',
    },
    {
        name: 'category.count',
        category: 'count',
        units: [
            { label: 'unit.piece', value: 'piece', factor: 1 },
            { label: 'unit.dz', value: 'dz', factor: 12 },
            { label: 'unit.pair', value: 'pair', factor: 2 },
            { label: 'unit.score', value: 'score', factor: 20 },
            { label: 'unit.gross', value: 'gross', factor: 144 },
        ],
        defaultUnit: 'piece',
    },
];
