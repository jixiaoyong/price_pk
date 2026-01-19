<script setup lang="ts">
  import { ref } from 'vue';
  import { Plus, SortAsc, Share2, Camera, Eraser } from 'lucide-vue-next';
  import { usePriceStore } from '../stores/usePriceStore';
  import ConfirmDialog from './ConfirmDialog.vue';
  import ToastMessage from './ToastMessage.vue';

  const store = usePriceStore();

  const emit = defineEmits(['screenshot']);
  const showClearConfirm = ref(false);
  const showToast = ref(false);
  const toastMessage = ref('');
  const toastType = ref<'success' | 'info' | 'warning' | 'error'>('success');
  const showManualCopyDialog = ref(false);
  const manualCopyUrl = ref('');

  const showSuccessToast = (message: string) => {
    toastMessage.value = message;
    toastType.value = 'success';
    showToast.value = true;
  };

  const onShareLink = async () => {
    const url = store.generateShareUrl();

    // 尝试使用现代 Clipboard API
    if (navigator.clipboard && window.isSecureContext) {
      try {
        await navigator.clipboard.writeText(url);
        showSuccessToast('分享链接已复制到剪贴板');
        return;
      } catch (err) {
        console.warn('Clipboard API failed, trying fallback', err);
      }
    }

    // Fallback: 使用临时 textarea 元素
    const textArea = document.createElement('textarea');
    textArea.value = url;
    textArea.style.position = 'fixed';
    textArea.style.left = '-9999px';
    textArea.style.top = '-9999px';
    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();

    try {
      const success = document.execCommand('copy');
      if (success) {
        showSuccessToast('分享链接已复制到剪贴板');
      } else {
        // 如果复制失败，显示链接让用户手动复制
        manualCopyUrl.value = url;
        showManualCopyDialog.value = true;
      }
    } catch (err) {
      console.error('Fallback copy failed', err);
      manualCopyUrl.value = url;
      showManualCopyDialog.value = true;
    } finally {
      document.body.removeChild(textArea);
    }
  };

  const onClear = () => {
    showClearConfirm.value = true;
  };

  const confirmClear = () => {
    store.clearAll();
    showClearConfirm.value = false;
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

  <ConfirmDialog v-if="showClearConfirm" message="确定要清除当前分类的所有商品数据吗？此操作无法撤销。" confirm-text="确定清空" :danger="true"
    @confirm="confirmClear" @cancel="showClearConfirm = false" />

  <!-- 手动复制链接弹窗 -->
  <ConfirmDialog v-if="showManualCopyDialog" title="复制链接" :message="'请长按下方链接手动复制：\n' + manualCopyUrl" confirm-text="知道了"
    @confirm="showManualCopyDialog = false" @cancel="showManualCopyDialog = false" />

  <!-- Toast 提示 -->
  <ToastMessage v-if="showToast" :message="toastMessage" :type="toastType" @close="showToast = false" />
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
