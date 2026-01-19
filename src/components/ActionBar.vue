<script setup lang="ts">
import { Plus, SortAsc, Share2, Camera, Eraser } from 'lucide-vue-next';
import { usePriceStore } from '../stores/usePriceStore';

const store = usePriceStore();

const emit = defineEmits(['screenshot']);

const onShareLink = async () => {
  const url = store.generateShareUrl();
  try {
    await navigator.clipboard.writeText(url);
    alert('分享链接已复制到剪辑板');
  } catch (err) {
    console.error('Failed to copy', err);
  }
};

const onClear = () => {
  if (confirm('确定要清除当前页面的所有数据吗？')) {
    store.clearAll();
  }
};
</script>

<template>
  <div class="action-bar glass-panel">
    <button class="action-btn primary" @click="store.addItem" title="添加商品">
      <Plus :size="20" />
      <span>添加</span>
    </button>
    
    <div class="divider"></div>

    <button class="action-btn" @click="store.sortItems" title="按价格排序">
      <SortAsc :size="20" />
      <span>排序</span>
    </button>

    <button class="action-btn" @click="onShareLink" title="复制分享链接">
      <Share2 :size="20" />
      <span>链接</span>
    </button>

    <button class="action-btn" @click="emit('screenshot')" title="生成截图">
      <Camera :size="20" />
      <span>截图</span>
    </button>

    <button class="action-btn danger" @click="onClear" title="清除所有">
      <Eraser :size="20" />
      <span>清空</span>
    </button>
  </div>
</template>

<style scoped>
.action-bar {
  position: fixed;
  bottom: 2rem;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  align-items: center;
  padding: 8px 16px;
  border-radius: 24px;
  gap: 8px;
  z-index: 100;
  width: max-content;
  max-width: 90vw;
}

.action-btn {
  flex-direction: column;
  padding: 8px;
  min-width: 54px;
  background: transparent;
  color: var(--text-main);
  font-size: 0.75rem;
  gap: 4px;
}

.action-btn:hover {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 12px;
}

.action-btn.primary {
  color: var(--primary);
}

.action-btn.danger {
  color: var(--danger);
}

.divider {
  width: 1px;
  height: 24px;
  background: var(--glass-border);
  margin: 0 4px;
}

@media (max-width: 400px) {
  .action-btn span {
    display: none;
  }
  .action-btn {
    min-width: 44px;
  }
}
</style>
