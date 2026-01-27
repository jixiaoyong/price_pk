<script setup lang="ts">
  import { Scale, Droplets, Hash, Ruler, Square } from 'lucide-vue-next';
  import { usePriceStore } from '../stores/usePriceStore';
  import type { UnitCategory } from '../types';

  const store = usePriceStore();

  const iconMap: Record<UnitCategory, any> = {
    weight: Scale,
    volume: Droplets,
    count: Hash,
    length: Ruler,
    area: Square,
  };
</script>

<template>
  <div class="bg-white p-1 rounded-xl shadow-sm border border-slate-200 grid grid-cols-5 gap-1 mb-5"
    style="background-color: #ffffff; border-color: #e2e8f0;">
    <button v-for="(cat, index) in store.categories" :key="cat.name" @click="store.currentCategoryIndex = index"
      class="flex flex-col items-center justify-center gap-1 py-2 rounded-lg text-[10px] font-bold transition-all duration-200"
      :class="store.currentCategoryIndex === index
        ? 'shadow-md'
        : ''" :style="store.currentCategoryIndex === index
          ? { backgroundColor: '#007AFF', color: '#ffffff' }
          : { color: '#94a3b8', backgroundColor: 'transparent' }">
      <component :is="iconMap[cat.category]" class="w-4 h-4" />
      {{ cat.name }}
    </button>
  </div>
</template>
