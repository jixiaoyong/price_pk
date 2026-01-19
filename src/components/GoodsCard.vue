<script setup lang="ts">
  import { computed } from 'vue';
  import { Trash2 } from 'lucide-vue-next';
  import type { GoodsItem, CategoryData } from '../types';
  import { usePriceStore } from '../stores/usePriceStore';

  const props = defineProps<{
    item: GoodsItem;
    category: CategoryData;
    isCheapest: boolean;
  }>();

  const store = usePriceStore();

  const unitPrice = computed(() => {
    const price = store.calculateUnitPrice(props.item, props.category);
    if (price === Infinity) return null;
    return price.toFixed(4);
  });

  const onRemove = () => {
    store.removeItem(props.item.id);
  };
</script>

<template>
  <div class="goods-card glass-panel" :class="{ 'is-cheapest': isCheapest }">
    <div class="card-header">
      <input v-model="item.name" class="name-input" placeholder="商品名称" />
      <button class="delete-btn" @click="onRemove">
        <Trash2 :size="18" />
      </button>
    </div>

    <div class="card-body">
      <div class="input-group">
        <label>单价 (元)</label>
        <input v-model.number="item.price" type="number" step="0.01" placeholder="0.00" />
      </div>

      <div class="input-group">
        <label>规格 ({{ item.unit }})</label>
        <div class="amount-wrap">
          <input v-model.number="item.amount" type="number" placeholder="0" />
          <select v-model="item.unit">
            <option v-for="u in category.units" :key="u.value" :value="u.value">
              {{ u.label }}
            </option>
          </select>
        </div>
      </div>
    </div>

    <div v-if="unitPrice" class="card-footer">
      <div class="result-label">单价 (元/{{category.units.find(u => u.factor === 1)?.label}})</div>
      <div class="result-value">{{ unitPrice }}</div>
    </div>
  </div>
</template>

<style scoped>
  .goods-card {
    border-radius: 12px;
    padding: 0.875rem;
    margin-bottom: 0.75rem;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    position: relative;
    overflow: hidden;
  }

  .is-cheapest {
    border: 2px solid var(--success);
    background: rgba(16, 185, 129, 0.08);
    box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.15);
  }

  .is-cheapest::before {
    content: '最划算';
    position: absolute;
    top: 0;
    right: 0;
    background: var(--success);
    color: white;
    padding: 2px 12px;
    font-size: 0.75rem;
    font-weight: 600;
    border-bottom-left-radius: 12px;
  }

  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 0.5rem;
  }

  .name-input {
    border: none;
    background: transparent;
    font-size: 1.1rem;
    font-weight: 600;
    padding: 4px;
    width: 100%;
  }

  .name-input:focus {
    background: rgba(255, 255, 255, 0.1);
    box-shadow: none;
  }

  .delete-btn {
    background: transparent;
    color: var(--text-muted);
    padding: 8px;
  }

  .delete-btn:hover {
    color: var(--danger);
    background: rgba(239, 68, 68, 0.1);
    border-radius: 50%;
  }

  .card-body {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 0.75rem;
  }

  .input-group {
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
  }

  .input-group label {
    font-size: 0.8rem;
    color: var(--text-muted);
  }

  .input-group input {
    width: 100%;
    padding: 8px 10px;
    border-radius: 6px;
    font-size: 0.95rem;
    border: 1px solid #d1d5db;
  }

  .amount-wrap {
    display: flex;
    gap: 4px;
  }

  .amount-wrap input {
    flex: 1;
  }

  .amount-wrap select {
    padding: 6px;
    border-radius: 6px;
    border: 1px solid #d1d5db;
    background: var(--glass-bg);
    color: inherit;
    font-size: 0.9rem;
  }

  .card-footer {
    margin-top: 0.75rem;
    padding-top: 0.75rem;
    border-top: 1px solid var(--glass-border);
    display: flex;
    justify-content: space-between;
    align-items: baseline;
  }

  .result-label {
    font-size: 0.8rem;
    color: var(--text-muted);
  }

  .result-value {
    font-size: 1.25rem;
    font-weight: 700;
    color: var(--primary);
  }

  .is-cheapest .result-value {
    color: var(--success);
  }
</style>
