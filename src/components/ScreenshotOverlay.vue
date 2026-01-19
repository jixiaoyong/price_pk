<script setup lang="ts">
  import { ref, onMounted, onUnmounted, nextTick } from 'vue';
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

  // 检测是否支持复制图片到剪贴板
  const canCopyImage = typeof ClipboardItem !== 'undefined' && typeof navigator?.clipboard?.write === 'function';

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
        await nextTick();

        // 2. 创建用于截图的临时容器
        const screenshotContainer = document.createElement('div');
        screenshotContainer.style.position = 'fixed';
        screenshotContainer.style.left = '-9999px';
        screenshotContainer.style.top = '0';
        screenshotContainer.style.width = element.offsetWidth + 'px';
        screenshotContainer.style.background = '#f8fafc';
        document.body.appendChild(screenshotContainer);

        // 3. 克隆原始内容
        const clone = element.cloneNode(true) as HTMLElement;
        clone.style.width = '100%';
        clone.style.margin = '0';
        clone.style.padding = '20px';
        clone.style.boxSizing = 'border-box';

        // 移除底部的空白占位组件 (用于适配固定底部的操作栏)
        const spacers = clone.querySelectorAll('div[style*="height: 100px"]');
        spacers.forEach(s => (s as HTMLElement).style.display = 'none');

        // 临时移除 glass 效果以提升截图质量
        const cards = clone.querySelectorAll('.glass-panel');
        cards.forEach((card) => {
          const el = card as HTMLElement;
          el.style.backdropFilter = 'none';
          (el.style as any).webkitBackdropFilter = 'none';
          el.style.background = 'rgba(255, 255, 255, 0.95)';
          el.style.boxShadow = '0 4px 6px -1px rgb(0 0 0 / 0.1)';
        });

        screenshotContainer.appendChild(clone);

        // 4. 创建并添加页脚
        const footer = document.createElement('div');
        footer.className = 'screenshot-footer';
        footer.style.padding = '24px 20px';
        footer.style.marginTop = '4px';
        footer.style.textAlign = 'center';
        footer.style.borderTop = '1px solid #f1f5f9';
        footer.style.background = '#ffffff';

        const siteUrl = 'https://jixiaoyong.github.io/price_pk';
        const baseUrl = import.meta.env.BASE_URL;

        footer.innerHTML = `
          <div style="margin-bottom: 12px; text-align: center;">
            <div style="display: flex; align-items: center; justify-content: center; gap: 8px; margin-bottom: 4px;">
              <img src="${baseUrl}pwa-192x192.png" style="width: 24px; height: 24px; flex-shrink: 0; object-fit: contain;" />
              <span style="font-size: 20px; font-weight: bold; color: #1e293b; white-space: nowrap;">${__APP_NAME__}</span>
            </div>
            <p style="margin: 0; color: #64748b; font-size: 13px; text-align: center; width: 100%; white-space: nowrap;">${__APP_DESCRIPTION__}</p>
          </div>
          <div style="margin: 16px 0; border-top: 1px solid #f1f5f9; width: 60px; margin-left: auto; margin-right: auto;"></div>
          <div style="margin-bottom: 8px; text-align: center;">
            <p style="margin: 0 0 12px 0; color: #1e293b; font-size: 14px; font-weight: 500; text-align: center; width: 100%;">长按或扫描二维码访问：</p>
            <div style="display: flex; justify-content: center; width: 100%;">
              <img src="${baseUrl}qrcode.png" style="width: 120px; height: 120px; border: 1px solid #e2e8f0; border-radius: 8px; padding: 4px;" />
            </div>
            <p style="margin: 12px 0 0 0; color: #94a3b8; font-size: 12px; font-family: monospace; text-align: center; width: 100%;">${siteUrl}</p>
          </div>
        `;
        screenshotContainer.appendChild(footer);

        // 5. 执行截图
        const canvas = await html2canvas(screenshotContainer, {
          backgroundColor: '#f8fafc',
          scale: 2,
          useCORS: true,
          logging: false,
          allowTaint: true,
        });

        // 6. 添加外边距
        const padding = 20;
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

        // 7. 清理临时容器
        document.body.removeChild(screenshotContainer);
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

    try {
      const blob = await new Promise<Blob | null>((resolve) => {
        canvasRef.value!.toBlob(resolve, 'image/png');
      });

      if (!blob) {
        throw new Error('Failed to create blob');
      }

      // 直接尝试复制，让浏览器决定是否支持
      const item = new ClipboardItem({ 'image/png': blob });
      await navigator.clipboard.write([item]);

      copySuccess.value = true;
      setTimeout(() => {
        copySuccess.value = false;
      }, 2000);
    } catch (err) {
      console.error('Copy failed', err);
      // 只在实际失败时显示提示
      errorMessage.value = '复制失败，请使用下载功能或长按图片保存';
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
        <p class="hint">{{ canCopyImage ? '您可以使用下方按钮' : '您可以长按图片保存，或点击下载' }}</p>
        <div v-if="!loading" class="btn-group">
          <button v-if="canCopyImage" class="action-btn copy-btn" @click="onCopy">
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
    overflow-x: hidden;
    padding: 1rem;
    background: var(--bg-gradient);
    -webkit-overflow-scrolling: touch;
    min-height: 200px;
  }

  .preview-img {
    max-width: 100%;
    border-radius: 8px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
    display: block;
  }

  .loading {
    color: var(--text-muted);
    text-align: center;
    padding: 2rem;
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
