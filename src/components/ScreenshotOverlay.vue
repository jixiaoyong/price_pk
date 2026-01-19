<script setup lang="ts">
  import { ref, onMounted, onUnmounted } from 'vue';
  import html2canvas from 'html2canvas';
  import { X, Download, Copy } from 'lucide-vue-next';
  import ConfirmDialog from './ConfirmDialog.vue';

  const props = defineProps<{
    targetId: string;
  }>();

  const emit = defineEmits(['close']);

  const imgUrl = ref('');
  const canvasRef = ref<HTMLCanvasElement | null>(null);
  const loading = ref(true);
  const copySuccess = ref(false);
  const errorDialogVisible = ref(false);
  const errorMessage = ref('');

  // 防止背景滚动穿透
  onMounted(() => {
    document.body.style.overflow = 'hidden';
  });

  onUnmounted(() => {
    document.body.style.overflow = '';
  });

  onMounted(async () => {
    const element = document.getElementById(props.targetId);
    if (element) {
      try {
        // 临时移除 glass 效果以提升截图质量
        const cards = element.querySelectorAll('.glass-panel');
        const originalStyles: string[] = [];
        cards.forEach((card, i) => {
          const el = card as HTMLElement;
          originalStyles[i] = el.style.cssText;
          el.style.backdropFilter = 'none';
          (el.style as any).webkitBackdropFilter = 'none';
          el.style.background = 'rgba(255, 255, 255, 0.95)';
        });

        const canvas = await html2canvas(element, {
          backgroundColor: '#f8fafc',
          scale: 2,
          useCORS: true,
          logging: false,
          allowTaint: true,
        });

        // 添加内边距
        const padding = 40;
        const paddedCanvas = document.createElement('canvas');
        paddedCanvas.width = canvas.width + padding * 2;
        paddedCanvas.height = canvas.height + padding * 2;
        const ctx = paddedCanvas.getContext('2d');
        if (ctx) {
          ctx.fillStyle = '#f8fafc';
          ctx.fillRect(0, 0, paddedCanvas.width, paddedCanvas.height);
          ctx.drawImage(canvas, padding, padding);
        }

        canvasRef.value = paddedCanvas;
        imgUrl.value = paddedCanvas.toDataURL('image/png');

        // 恢复原有样式
        cards.forEach((card, i) => {
          (card as HTMLElement).style.cssText = originalStyles[i] || '';
        });
      } catch (err) {
        console.error('Screenshot failed', err);
      } finally {
        loading.value = false;
      }
    }
  });

  const onDownload = () => {
    const link = document.createElement('a');
    link.download = `price-pk-${Date.now()}.png`;
    link.href = imgUrl.value;
    link.click();
  };

  const onCopy = async () => {
    if (!canvasRef.value) return;

    // 检查 ClipboardItem API 是否可用
    if (typeof ClipboardItem === 'undefined' || !navigator.clipboard?.write) {
      errorMessage.value = '当前环境不支持复制图片到剪贴板，请使用下载功能或长按图片保存';
      errorDialogVisible.value = true;
      return;
    }

    try {
      const blob = await new Promise<Blob | null>((resolve) => {
        canvasRef.value!.toBlob(resolve, 'image/png');
      });

      if (blob) {
        const item = new ClipboardItem({ 'image/png': blob });
        await navigator.clipboard.write([item]);
        copySuccess.value = true;
        setTimeout(() => {
          copySuccess.value = false;
        }, 2000);
      }
    } catch (err) {
      console.error('Copy failed', err);
      errorMessage.value = '复制失败，请使用下载功能';
      errorDialogVisible.value = true;
    }
  };
</script>

<template>
  <div class="modal-overlay" @click.self="emit('close')">
    <div class="modal-content glass-panel">
      <div class="modal-header">
        <h3>分享截图</h3>
        <button class="close-btn" @click="emit('close')">
          <X :size="20" />
        </button>
      </div>

      <div class="preview-area">
        <div v-if="loading" class="loading">正在生成图片...</div>
        <img v-else :src="imgUrl" class="preview-img" alt="截图预览" />
      </div>

      <div class="modal-footer">
        <p class="hint">您可以长按图片保存，或使用下方按钮</p>
        <div v-if="!loading" class="btn-group">
          <button class="action-btn copy-btn" @click="onCopy">
            <Copy :size="20" />
            {{ copySuccess ? '已复制' : '复制图片' }}
          </button>
          <button class="action-btn download-btn" @click="onDownload">
            <Download :size="20" />
            下载图片
          </button>
        </div>
      </div>
    </div>

    <!-- 错误提示弹窗 -->
    <ConfirmDialog v-if="errorDialogVisible" title="提示" :message="errorMessage" confirmText="知道了"
      @confirm="errorDialogVisible = false" @cancel="errorDialogVisible = false" />
  </div>
</template>

<style scoped>
  .modal-overlay {
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(4px);
    z-index: 1000;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 1.5rem;
  }

  .modal-content {
    width: 100%;
    max-width: 480px;
    border-radius: 20px;
    display: flex;
    flex-direction: column;
    max-height: 85vh;
  }

  .modal-header {
    padding: 1.25rem;
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid var(--glass-border);
  }

  .modal-header h3 {
    margin: 0;
    font-size: 1.1rem;
  }

  .close-btn {
    background: transparent;
    color: var(--text-muted);
  }

  .preview-area {
    flex: 1;
    overflow-y: auto;
    padding: 1rem;
    background: var(--bg-gradient);
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 200px;
  }

  .preview-img {
    max-width: 100%;
    border-radius: 8px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  }

  .loading {
    color: var(--text-muted);
  }

  .modal-footer {
    padding: 1.25rem;
    border-top: 1px solid var(--glass-border);
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .hint {
    font-size: 0.8rem;
    color: var(--text-muted);
    text-align: center;
    margin: 0;
  }

  .btn-group {
    display: flex;
    gap: 0.75rem;
  }

  .action-btn {
    flex: 1;
    padding: 12px;
    border-radius: 12px;
    font-weight: 600;
    font-size: 0.9rem;
  }

  .copy-btn {
    background: var(--glass-bg);
    border: 1px solid var(--primary);
    color: var(--primary);
  }

  .download-btn {
    background: var(--primary-gradient);
    color: white;
  }
</style>
