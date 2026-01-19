<script setup lang="ts">
  import { usePriceStore } from '../stores/usePriceStore';

  const store = usePriceStore();
</script>

<template>
  <div class="tabs-container glass-panel">
    <button v-for="(cat, index) in store.categories" :key="cat.name" class="tab-btn"
      :class="{ 'active': store.currentCategoryIndex === index }" @click="store.currentCategoryIndex = index">
      {{ cat.name }}
    </button>
  </div>
</template>

<style scoped>
  .tabs-container {
    display: flex;
    padding: 4px;
    border-radius: 12px;
    margin-bottom: 2rem;
    gap: 4px;
  }

  .tab-btn {
    flex: 1;
    padding: 8px 4px;
    border-radius: 8px;
    font-weight: 600;
    font-size: 0.85rem;
    white-space: nowrap;
    color: var(--text-muted);
    background: transparent;
  }

  .tab-btn.active {
    background: var(--primary-gradient);
    color: white;
    box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
  }
</style>
