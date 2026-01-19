import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import type { CategoryData, GoodsItem } from '../types';
import LZString from 'lz-string';

// 兼容性 UUID 生成器 (兜底非 Secure Context 如局域网 IP 访问)
const safeUuid = () => {
    if (typeof crypto !== 'undefined' && crypto.randomUUID) {
        return crypto.randomUUID();
    }
    return Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
};

export const usePriceStore = defineStore('price', () => {
    const currentCategoryIndex = ref<number>(0);

    const categories = ref<CategoryData[]>([
        {
            name: '重量',
            category: 'weight',
            units: [
                { label: 'mg', value: 'mg', factor: 0.001 },
                { label: 'g', value: 'g', factor: 1 },
                { label: 'kg', value: 'kg', factor: 1000 },
                { label: 't', value: 't', factor: 1000000 },
            ],
            items: [
                { id: safeUuid(), name: '商品1', price: null, amount: null, unit: 'g' },
                { id: safeUuid(), name: '商品2', price: null, amount: null, unit: 'g' },
            ],
        },
        {
            name: '体积',
            category: 'volume',
            units: [
                { label: 'ml', value: 'ml', factor: 1 },
                { label: 'l', value: 'l', factor: 1000 },
            ],
            items: [
                { id: safeUuid(), name: '商品1', price: null, amount: null, unit: 'ml' },
                { id: safeUuid(), name: '商品2', price: null, amount: null, unit: 'ml' },
            ],
        },
    ]);

    const currentCategory = computed(() => categories.value[currentCategoryIndex.value] as CategoryData);

    // 计算单位价格 (每基准单位的价格)
    const calculateUnitPrice = (item: GoodsItem, category: CategoryData) => {
        if (item.price === null || item.amount === null || item.amount <= 0) return Infinity;
        const unitInfo = category.units.find(u => u.value === item.unit);
        if (!unitInfo) return Infinity;
        const totalBaseAmount = item.amount * unitInfo.factor;
        return item.price / totalBaseAmount;
    };

    // 获取当前分类下最低单价
    const minUnitPrice = computed(() => {
        const prices = currentCategory.value.items.map(item => calculateUnitPrice(item, currentCategory.value));
        const validPrices = prices.filter(p => p !== Infinity && p > 0);
        // 只有当有 2 个及以上的数据项有有效值时，才执行对比逻辑
        if (validPrices.length < 2) return Infinity;
        return Math.min(...validPrices);
    });

    const addItem = () => {
        const cat = currentCategory.value;
        const defaultUnit = cat.category === 'weight' ? 'g' : 'ml';
        cat.items.push({
            id: safeUuid(),
            name: `商品${cat.items.length + 1}`,
            price: null,
            amount: null,
            unit: defaultUnit,
        });
    };

    const removeItem = (id: string) => {
        const index = currentCategory.value.items.findIndex(item => item.id === id);
        if (index !== -1) {
            currentCategory.value.items.splice(index, 1);
        }
    };

    const clearAll = () => {
        const cat = currentCategory.value;
        const defaultUnit = cat.category === 'weight' ? 'g' : 'ml';
        cat.items = [
            { id: safeUuid(), name: '商品1', price: null, amount: null, unit: defaultUnit },
            { id: safeUuid(), name: '商品2', price: null, amount: null, unit: defaultUnit },
        ];
    };

    const sortItems = () => {
        currentCategory.value.items.sort((a, b) => {
            const pA = calculateUnitPrice(a, currentCategory.value);
            const pB = calculateUnitPrice(b, currentCategory.value);
            return pA - pB;
        });
    };

    // --- URL Persistence ---
    const getShareData = () => {
        return {
            tab: currentCategoryIndex.value,
            weightGoods: (categories.value[0] as CategoryData).items.map(i => ({
                name: i.name,
                price: i.price,
                count: i.amount,
                unit: i.unit,
            })),
            volumeGoods: (categories.value[1] as CategoryData).items.map(i => ({
                name: i.name,
                price: i.price,
                count: i.amount,
                unit: i.unit,
            })),
        };
    };

    const generateShareUrl = () => {
        const data = getShareData();
        const jsonStr = JSON.stringify(data);
        const compressed = LZString.compressToEncodedURIComponent(jsonStr);
        const url = new URL(window.location.href);
        url.searchParams.set('data', compressed);
        return url.toString();
    };

    const loadFromUrl = () => {
        const params = new URLSearchParams(window.location.search);
        const compressed = params.get('data');
        if (!compressed) return;

        try {
            const jsonStr = LZString.decompressFromEncodedURIComponent(compressed);
            if (!jsonStr) return;
            const data = JSON.parse(jsonStr);

            currentCategoryIndex.value = parseInt(data.tab) || 0;

            if (data.weightGoods) {
                (categories.value[0] as CategoryData).items = data.weightGoods.map((i: any) => ({
                    id: safeUuid(),
                    name: i.name,
                    price: i.price,
                    amount: i.count,
                    unit: i.unit,
                }));
            }
            if (data.volumeGoods) {
                (categories.value[1] as CategoryData).items = data.volumeGoods.map((i: any) => ({
                    id: safeUuid(),
                    name: i.name,
                    price: i.price,
                    amount: i.count,
                    unit: i.unit,
                }));
            }
        } catch (e) {
            console.error('Failed to load data from URL', e);
        }
    };

    return {
        categories,
        currentCategoryIndex,
        currentCategory,
        minUnitPrice,
        calculateUnitPrice,
        addItem,
        removeItem,
        clearAll,
        sortItems,
        generateShareUrl,
        loadFromUrl,
    };
});
