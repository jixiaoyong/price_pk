<script setup lang="ts">
import { ref, onMounted } from 'vue';
import html2canvas from 'html2canvas';
import { X, Download } from 'lucide-vue-next';

const props = defineProps<{
  targetId: string;
}>();

const emit = defineEmits(['close']);

const imgUrl = ref('');
const loading = ref(true);

onMounted(async () => {
  const element = document.getElementById(props.targetId);
  if (element) {
    try {
      const canvas = await html2canvas(element, {
        backgroundColor: null,
        scale: 2,
        useCORS: true,
      });
      imgUrl.value = canvas.toDataURL('image/png');
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
        <p class="hint">您可以长按上方图片保存，或点击下方按钮下载</p>
        <button v-if="!loading" class="download-btn" @click="onDownload">
          <Download :size="20" />
          下载图片
        </button>
      </div>
    </div>
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

.download-btn {
  width: 100%;
  padding: 12px;
  background: var(--primary-gradient);
  color: white;
  border-radius: 12px;
  font-weight: 600;
}
</style>
