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
    return Array.from({ length: count }, (_, i) => ({
        id: generateId(),
        name: `商品${i + 1}`,
        price: null,
        amount: null,
        unit: defaultUnit,
    }));
};

export const INITIAL_CATEGORIES: Omit<CategoryData, 'items'>[] = [
    {
        name: '重量',
        category: 'weight',
        units: [
            { label: '克 (g)', value: 'g', factor: 1 },
            { label: '千克 (kg)', value: 'kg', factor: 1000 },
            { label: '斤 (500g)', value: 'jin', factor: 500 },
            { label: '两 (50g)', value: 'liang', factor: 50 },
            { label: '磅 (lb)', value: 'lb', factor: 453.592 },
            { label: '盎司 (oz)', value: 'oz', factor: 28.3495 },
        ],
        defaultUnit: 'g',
    },
    {
        name: '体积',
        category: 'volume',
        units: [
            { label: '毫升 (ml)', value: 'ml', factor: 1 },
            { label: '升 (L)', value: 'l', factor: 1000 },
            { label: '立方米 (m³)', value: 'm3', factor: 1000000 },
            { label: '立方厘米', value: 'cm3', factor: 1 },
            { label: '液盎司', value: 'fl_oz', factor: 29.5735 },
            { label: '品脱', value: 'pt', factor: 473.176 },
            { label: '加仑', value: 'gal', factor: 3785.41 },
        ],
        defaultUnit: 'ml',
    },
    {
        name: '长度',
        category: 'length',
        units: [
            { label: '米 (m)', value: 'm', factor: 100 },
            { label: '厘米 (cm)', value: 'cm', factor: 1 },
            { label: '毫米 (mm)', value: 'mm', factor: 0.1 },
            { label: '码 (yd)', value: 'yd', factor: 91.44 },
            { label: '英尺 (ft)', value: 'ft', factor: 30.48 },
        ],
        defaultUnit: 'm',
    },
    {
        name: '面积',
        category: 'area',
        units: [
            { label: '平米 (m²)', value: 'm2', factor: 1 },
            { label: '平方英尺', value: 'sq_ft', factor: 0.092903 },
            { label: '亩', value: 'mu', factor: 666.667 },
            { label: '公顷', value: 'ha', factor: 10000 },
        ],
        defaultUnit: 'm2',
    },
    {
        name: '数量',
        category: 'count',
        units: [
            { label: '个/件', value: '个', factor: 1 },
            { label: '打 (12)', value: 'dz', factor: 12 },
            { label: '双 (2)', value: 'pair', factor: 2 },
            { label: '二十', value: 'score', factor: 20 },
            { label: '罗 (144)', value: 'gross', factor: 144 },
        ],
        defaultUnit: '个',
    },
];
