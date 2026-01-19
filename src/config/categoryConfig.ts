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
            { label: 'mg', value: 'mg', factor: 0.001 },
            { label: 'g', value: 'g', factor: 1 },
            { label: 'kg', value: 'kg', factor: 1000 },
            { label: 't', value: 't', factor: 1000000 },
        ],
        defaultUnit: 'g',
    },
    {
        name: '体积',
        category: 'volume',
        units: [
            { label: 'mL', value: 'mL', factor: 1 },
            { label: 'L', value: 'L', factor: 1000 },
        ],
        defaultUnit: 'mL',
    },
    {
        name: '数量',
        category: 'count',
        units: [
            { label: '个', value: '个', factor: 1 },
        ],
        defaultUnit: '个',
    },
    {
        name: '长度',
        category: 'length',
        units: [
            { label: 'cm', value: 'cm', factor: 0.01 },
            { label: 'm', value: 'm', factor: 1 },
            { label: 'km', value: 'km', factor: 1000 },
        ],
        defaultUnit: 'm',
    },
    {
        name: '面积',
        category: 'area',
        units: [
            { label: 'cm²', value: 'cm²', factor: 0.0001 },
            { label: 'm²', value: 'm²', factor: 1 },
        ],
        defaultUnit: 'm²',
    },
];
