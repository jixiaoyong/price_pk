import { defineStore } from 'pinia';
import { ref, computed, watch } from 'vue';
import type { CategoryData, GoodsItem } from '../types';
import LZString from 'lz-string';
import { INITIAL_CATEGORIES, createDefaultItems, generateId } from '../config/categoryConfig';

const STORAGE_KEY = 'price_pk_data';

export const usePriceStore = defineStore('price', () => {
    const currentCategoryIndex = ref<number>(0);

    // 初始化分类数据，使用配置文件中的辅助函数生成默认商品
    const categories = ref<CategoryData[]>(
        INITIAL_CATEGORIES.map(cat => ({
            ...cat,
            items: createDefaultItems(cat.defaultUnit),
        })) as CategoryData[]
    );

    const currentCategory = computed(() => categories.value[currentCategoryIndex.value]!);

    // 计算单位价格 (每基准单位的价格)
    const calculateUnitPrice = (item: GoodsItem, category: CategoryData) => {
        if (item.price === null || item.amount === null || item.amount <= 0) return Infinity;
        // 关键：查找单位时也进行标准化处理
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
        currentCategory.value.items.push({
            id: generateId(),
            name: '',
            price: null,
            amount: null,
            unit: currentCategory.value.defaultUnit,
        });
    };

    const removeItem = (id: string) => {
        if (currentCategory.value.items.length > 1) {
            currentCategory.value.items = currentCategory.value.items.filter(item => item.id !== id);
        } else {
            // 如果只剩一个，则清空内容而不是删除
            const item = currentCategory.value.items[0]!;
            item.price = null;
            item.amount = null;
            item.unit = currentCategory.value.defaultUnit;
        }
    };

    const clearAll = () => {
        currentCategory.value.items = createDefaultItems(currentCategory.value.defaultUnit);
    };

    const sortItems = () => {
        currentCategory.value.items.sort((a, b) => {
            const priceA = calculateUnitPrice(a, currentCategory.value);
            const priceB = calculateUnitPrice(b, currentCategory.value);
            return priceA - priceB;
        });
    };

    // 生成分享 URL
    const generateShareUrl = () => {
        const data = {
            c: currentCategoryIndex.value,
            i: currentCategory.value.items.map(item => ({
                n: item.name,
                p: item.price,
                a: item.amount,
                u: item.unit,
            })),
        };
        const compressed = LZString.compressToEncodedURIComponent(JSON.stringify(data));
        const url = new URL(window.location.href);
        url.searchParams.set('d', compressed);
        return url.toString();
    };

    // 从 URL 加载数据
    const loadFromUrl = (dataStr: string) => {
        try {
            const decompressed = LZString.decompressFromEncodedURIComponent(dataStr);
            if (!decompressed) return;
            const data = JSON.parse(decompressed);

            if (data.c !== undefined) currentCategoryIndex.value = data.c;
            if (data.i && Array.isArray(data.i)) {
                currentCategory.value.items = data.i.map((item: any) => ({
                    id: generateId(),
                    name: item.n,
                    price: item.p,
                    amount: item.a,
                    unit: item.u || currentCategory.value.defaultUnit,
                }));
            }
        } catch (e) {
            console.error('Failed to parse share data', e);
        }
    };

    // 保存到 LocalStorage
    const saveToLocalStorage = () => {
        const data = {
            currentCategoryIndex: currentCategoryIndex.value,
            // 只按名称匹配保存物品，这样如果分类顺序变了也能正确恢复
            categoriesData: categories.value.map(cat => ({
                name: cat.name,
                items: cat.items.map(item => ({
                    n: item.name,
                    p: item.price,
                    a: item.amount,
                    u: item.unit
                }))
            }))
        };
        localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
    };

    // 从 LocalStorage 加载
    const loadFromLocalStorage = () => {
        const stored = localStorage.getItem(STORAGE_KEY);
        if (!stored) return;

        try {
            const data = JSON.parse(stored);

            // 恢复分类索引
            if (typeof data.currentCategoryIndex === 'number' && data.currentCategoryIndex < categories.value.length) {
                currentCategoryIndex.value = data.currentCategoryIndex;
            }

            // 恢复各分类下的数据 (按名称匹配)
            if (data.categoriesData && Array.isArray(data.categoriesData)) {
                data.categoriesData.forEach((storedCat: any) => {
                    const localCat = categories.value.find(c => c.name === storedCat.name);
                    if (localCat && storedCat.items) {
                        localCat.items = storedCat.items.map((item: any) => ({
                            id: generateId(),
                            name: item.n,
                            price: item.p,
                            amount: item.a,
                            unit: item.u || localCat.defaultUnit
                        }));
                    }
                });
            }
        } catch (e) {
            console.error('Failed to load from localStorage', e);
        }
    };

    // 自动保存
    watch(categories, () => {
        saveToLocalStorage();
    }, { deep: true });

    watch(currentCategoryIndex, () => {
        saveToLocalStorage();
    });

    return {
        categories,
        currentCategoryIndex,
        currentCategory,
        minUnitPrice,
        addItem,
        removeItem,
        clearAll,
        sortItems,
        calculateUnitPrice,
        generateShareUrl,
        loadFromUrl,
        loadFromLocalStorage,
    };
});
