<script setup lang="ts">
  import { computed, ref } from 'vue';
  import { Trash2, Trophy, ArrowUp, X } from 'lucide-vue-next';
  import type { GoodsItem, CategoryData } from '../types';
  import { usePriceStore } from '../stores/usePriceStore';
  import CustomUnitSelect from './CustomUnitSelect.vue';

  const props = defineProps<{
    item: GoodsItem;
    category: CategoryData;
    isCheapest: boolean;
  }>();

  const store = usePriceStore();

  const unitPrice = computed(() => store.calculateUnitPrice(props.item, props.category));
  const hasData = computed(() => unitPrice.value !== Infinity);

  const percentDiff = computed(() => {
    if (hasData.value && !props.isCheapest && store.minUnitPrice !== Infinity && store.minUnitPrice > 0) {
      return ((unitPrice.value - store.minUnitPrice) / store.minUnitPrice) * 100;
    }
    return 0;
  });

  const formattedUnitPrice = computed(() => {
    if (!hasData.value) return '--.--';
    return unitPrice.value.toLocaleString('zh-CN', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 4
    });
  });


  const emit = defineEmits<{
    'request-delete': [id: string]
  }>();

  const onRemove = () => {
    emit('request-delete', props.item.id);
  };

  const updatePrice = (value: string) => {
    const num = parseFloat(value);
    if (!isNaN(num) && num >= 0) {
      props.item.price = num;
    } else if (value === '') {
      props.item.price = null;
    }
  };

  const handlePriceBlur = (e: FocusEvent) => {
    const target = e.target as HTMLInputElement;
    if (target.value) {
      const num = parseFloat(target.value);
      if (!isNaN(num)) {
        props.item.price = parseFloat(num.toFixed(2));
      }
    }
  };

  const clearPrice = () => {
    props.item.price = null;
  };

  // Track if unit dropdown is open to elevate z-index
  const isUnitDropdownOpen = ref(false);
  const handleDropdownToggle = (isOpen: boolean) => {
    isUnitDropdownOpen.value = isOpen;
  };
</script>

<template>
  <div class="relative transition-all duration-300 rounded-2xl p-4 overflow-visible" :class="isCheapest
    ? 'shadow-lg scale-[1.02]'
    : 'shadow-sm opacity-95'" :style="isUnitDropdownOpen
      ? { backgroundColor: '#ffffff', boxShadow: isCheapest ? '0 0 0 2px #007AFF, 0 10px 15px -3px rgba(219, 234, 254, 0.5)' : 'none', border: isCheapest ? 'none' : '1px solid #e2e8f0', zIndex: 1000 }
      : isCheapest
        ? { backgroundColor: '#ffffff', boxShadow: '0 0 0 2px #007AFF, 0 10px 15px -3px rgba(219, 234, 254, 0.5)', zIndex: 5 }
        : { backgroundColor: '#ffffff', border: '1px solid #e2e8f0', zIndex: 1 }">
    <!-- Winner Badge -->
    <div v-if="isCheapest"
      class="absolute -top-px -right-px text-white text-[10px] font-bold px-3 py-1 rounded-bl-xl rounded-tr-xl shadow-sm flex items-center gap-1 z-20"
      style="background-color: #007AFF;">
      <Trophy class="w-3 h-3" />
      首选
    </div>

    <!-- Expensive Badge -->
    <div v-if="!isCheapest && hasData && store.minUnitPrice !== Infinity"
      class="absolute top-0 right-0 text-[10px] font-bold px-2 py-1 rounded-bl-xl flex items-center gap-1"
      style="background-color: #fef2f2; color: #ef4444; border-left: 1px solid #fee2e2; border-bottom: 1px solid #fee2e2;">
      <ArrowUp class="w-3 h-3" />
      贵 {{ percentDiff.toFixed(0) }}%
    </div>

    <!-- Header: Name & Delete -->
    <div class="flex justify-between items-center mb-3">
      <input v-model="item.name" type="text"
        class="bg-transparent font-bold focus:outline-none w-32 text-base border-b border-dashed border-transparent transition-colors"
        :style="{ color: isCheapest ? '#007AFF' : '#334155' }" placeholder="商品名称" />
      <button v-if="store.currentCategory.items.length > 2" @click="onRemove" class="p-2 -mr-2" style="color: #cbd5e1;">
        <Trash2 class="w-4 h-4" />
      </button>
    </div>

    <!-- Inputs Row -->
    <div class="grid grid-cols-2 gap-3 mb-3">
      <!-- Price Input -->
      <div class="relative group rounded-xl transition-colors"
        :style="{ backgroundColor: isCheapest ? '#eff6ff' : '#f8fafc' }">
        <label class="text-[10px] font-bold absolute top-1.5 left-3 uppercase" style="color: #94a3b8;">价格</label>
        <input type="number" inputmode="decimal" min="0" :value="item.price"
          @input="e => updatePrice((e.target as HTMLInputElement).value)" @blur="handlePriceBlur"
          class="w-full pt-6 pb-2 px-3 bg-transparent outline-none text-xl font-semibold placeholder-slate-200"
          style="color: #1e293b;" placeholder="0" />
        <button v-if="item.price !== null" @click="clearPrice" class="absolute right-2 top-1/2 -translate-y-1/2 p-1"
          style="color: #cbd5e1;">
          <X class="w-4 h-4" />
        </button>
      </div>

      <!-- Amount & Unit Input -->
      <div class="flex rounded-xl overflow-visible transition-colors"
        :style="{ backgroundColor: isCheapest ? '#eff6ff' : '#f8fafc' }">
        <div class="relative flex-1" style="min-width: 0;">
          <label class="text-[10px] font-bold absolute top-1.5 left-3 uppercase" style="color: #94a3b8;">数量</label>
          <input v-model.number="item.amount" type="number" inputmode="decimal" min="0"
            class="w-full pt-6 pb-2 px-3 bg-transparent outline-none text-xl font-semibold placeholder-slate-200"
            style="color: #1e293b;" placeholder="0" />
        </div>
        <div class="w-auto rounded-r-xl flex-shrink-0"
          style="background-color: #f1f5f9; border-left: 1px solid #e2e8f0;">
          <CustomUnitSelect v-model="item.unit" :options="category.units" @dropdown-toggle="handleDropdownToggle" />
        </div>
      </div>
    </div>

    <!-- Result Row -->
    <div class="flex items-center justify-between pt-2 border-t"
      :style="{ borderColor: isCheapest ? '#dbeafe' : '#f1f5f9' }">
      <div class="flex items-center gap-2">
        <div class="text-[10px] font-medium" style="color: #94a3b8;">
          单价(/{{category.units.find(u => u.factor === 1)?.label || category.defaultUnit}})
        </div>
      </div>

      <div class="text-xl font-mono tracking-tight font-bold" :style="{ color: isCheapest ? '#007AFF' : '#cbd5e1' }">
        <span v-if="hasData">
          <span class="text-xs mr-0.5 align-top mt-1 inline-block">¥</span>
          {{ formattedUnitPrice }}
        </span>
        <span v-else style="color: #e2e8f0;">--.--</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
  /* Scoped styles removed in favor of Tailwind classes, matching example.txt */
</style>
