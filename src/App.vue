<script setup lang="ts">
  import { ref, onMounted } from 'vue';
  import { usePriceStore } from './stores/usePriceStore';
  import CategoryTabs from './components/CategoryTabs.vue';
  import GoodsCard from './components/GoodsCard.vue';
  import Toast from './components/Toast.vue';
  import ConfirmDialog from './components/ConfirmDialog.vue';
  import { Calculator, ArrowUpDown, Plus, RotateCcw, Link as LinkIcon, Image as ImageIcon } from 'lucide-vue-next';
  import { useRegisterSW } from 'virtual:pwa-register/vue';
  import domtoimage from 'dom-to-image';

  // PWA Service Worker registration
  useRegisterSW({
    onNeedRefresh() { },
    onOfflineReady() { },
  });

  const store = usePriceStore();
  const captureRef = ref<HTMLElement | null>(null);
  // const showShareModal = ref(false); // Removed

  // Toast State
  const showToast = ref(false);
  const toastMessage = ref('');
  const toastType = ref<'success' | 'error' | 'info'>('success');

  // Confirm Dialog State
  const showConfirm = ref(false);
  const confirmMessage = ref('');
  const confirmAction = ref<() => void>(() => { });
  const itemToDeleteId = ref<string | null>(null);

  onMounted(() => {
    const params = new URLSearchParams(window.location.search);
    if (params.has('d')) {
    } else {
      store.loadFromLocalStorage();
    }
  });

  const showToastMsg = (msg: string, type: 'success' | 'error' | 'info' = 'success') => {
    toastMessage.value = msg;
    toastType.value = type;
    showToast.value = true;
  };

  const onRequestDelete = (id: string) => {
    itemToDeleteId.value = id;
    confirmMessage.value = '确定要删除这个商品吗？';
    confirmAction.value = () => {
      if (itemToDeleteId.value) {
        store.removeItem(itemToDeleteId.value);
        itemToDeleteId.value = null;
      }
      showConfirm.value = false;
    };
    showConfirm.value = true;
  };

  const onReset = () => {
    confirmMessage.value = '确定要重置当前分类的所有数据吗？';
    confirmAction.value = () => {
      store.clearAll();
      showConfirm.value = false;
      showToastMsg('已重置', 'success');
    };
    showConfirm.value = true;
  };

  const copyLink = async () => {
    const url = store.generateShareUrl();

    // Try Modern API
    if (navigator.clipboard && window.isSecureContext) {
      try {
        await navigator.clipboard.writeText(url);
        showToastMsg('链接已复制！快去分享给朋友吧', 'success');
        return;
      } catch (err) {
        console.warn('Clipboard API failed, trying fallback', err);
      }
    }

    // Fallback strategy
    try {
      const textArea = document.createElement('textarea');
      textArea.value = url;
      textArea.style.position = 'fixed';
      textArea.style.left = '-9999px';
      textArea.style.top = '0';
      document.body.appendChild(textArea);
      textArea.focus();
      textArea.select();

      const successful = document.execCommand('copy');
      document.body.removeChild(textArea);

      if (successful) {
        showToastMsg('链接已复制！快去分享给朋友吧', 'success');
      } else {
        throw new Error('Fallback copy failed');
      }
    } catch (err) {
      showToastMsg('复制失败，请手动复制地址栏链接', 'error');
    }
  };

  const generateImage = async () => {
    if (!captureRef.value) {
      showToastMsg('无法获取截图区域，请刷新页面重试', 'error');
      return;
    }

    try {
      const scale = window.devicePixelRatio || 2;
      const dataUrl = await domtoimage.toPng(captureRef.value, {
        quality: 1,
        bgcolor: '#f8fafc',
        width: captureRef.value.offsetWidth * scale,
        height: captureRef.value.offsetHeight * scale,
        style: {
          transform: `scale(${scale})`,
          transformOrigin: 'top left',
          width: `${captureRef.value.offsetWidth}px`,
          height: `${captureRef.value.offsetHeight}px`
        }
      });

      // Try to copy to clipboard first
      try {
        const blob = await fetch(dataUrl).then(r => r.blob());
        await navigator.clipboard.write([
          new ClipboardItem({ 'image/png': blob })
        ]);
        showToastMsg('图片已复制到剪贴板', 'success');
        return;
      } catch (clipboardError) {
        console.log('Clipboard copy failed, falling back to download:', clipboardError);
      }

      // Fallback to download
      const link = document.createElement('a');
      link.href = dataUrl;
      link.download = `比价神器-${new Date().toLocaleDateString()}.png`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      showToastMsg('图片已保存', 'success');
    } catch (error) {
      console.error('dom-to-image error:', error);
      showToastMsg('生成图片出错，请手动截图', 'error');
    }
  };
</script>

<template>
  <div class="min-h-screen font-sans pb-32 safe-area-bottom" style="background-color: #f8fafc; color: #1e293b;">
    <!-- Top Navigation Bar -->
    <div
      class="backdrop-blur-md sticky top-0 z-20 shadow-sm flex items-center justify-between safe-area-top h-[56px] px-4"
      style="background-color: rgba(255, 255, 255, 0.8); border-bottom: 1px solid #f1f5f9;">
      <div class="flex items-center gap-2">
        <div class="p-1.5 rounded-lg shadow-sm" style="background-color: #007AFF;">
          <Calculator class="w-5 h-5 text-white" />
        </div>
        <h1 class="text-lg font-bold tracking-tight" style="color: #0f172a;">比价神器</h1>
      </div>
      <div class="flex items-center gap-1">
        <button @click="store.sortItems" class="p-2 rounded-full transition-colors" style="color: #64748b;"
          title="按单价排序">
          <ArrowUpDown class="w-5 h-5" />
        </button>
        <button @click="copyLink" class="p-2 rounded-full transition-colors" style="color: #64748b;" title="复制链接">
          <LinkIcon class="w-5 h-5" />
        </button>
        <button @click="generateImage" class="p-2 rounded-full transition-colors" style="color: #64748b;" title="保存图片">
          <ImageIcon class="w-5 h-5" />
        </button>
      </div>
    </div>

    <div ref="captureRef" class="min-h-full" style="background-color: #f8fafc;">
      <div class="max-w-md mx-auto p-4 space-y-5">

        <!-- Mode Selector -->
        <CategoryTabs />

        <!-- Goods List -->
        <div class="space-y-4 overflow-visible">
          <TransitionGroup enter-active-class="transition-all duration-300 ease-out"
            leave-active-class="transition-all duration-200 ease-in absolute w-full"
            enter-from-class="opacity-0 translate-y-4" leave-to-class="opacity-0 -translate-x-4"
            move-class="transition-all duration-300 ease-in-out">
            <GoodsCard v-for="item in store.currentCategory.items" :key="item.id" :item="item"
              :category="store.currentCategory"
              :is-cheapest="store.minUnitPrice !== Infinity && store.calculateUnitPrice(item, store.currentCategory) !== Infinity && store.calculateUnitPrice(item, store.currentCategory) === store.minUnitPrice"
              @request-delete="onRequestDelete" />
          </TransitionGroup>
        </div>

        <!-- Bottom Actions -->
        <div class="pt-4 pb-8 flex flex-col gap-3">
          <button @click="store.addItem"
            class="w-full py-3.5 text-white rounded-xl shadow-lg flex items-center justify-center gap-2 font-bold transition-all active:scale-[0.98]"
            style="background-color: #007AFF; box-shadow: 0 10px 15px -3px rgba(59, 130, 246, 0.3);">
            <Plus class="w-5 h-5" />
            添加对比项
          </button>

          <button @click="onReset" class="w-full py-3.5 rounded-xl font-bold flex items-center justify-center gap-2"
            style="background-color: #ffffff; color: #64748b; border: 1px solid #e2e8f0;">
            <RotateCcw class="w-4 h-4" />
            重置当前
          </button>
        </div>

        <!-- Screenshot Footer with Branding and QR Code -->
        <div class="mt-6 mb-4 px-4">
          <div class="flex items-center justify-between gap-4">
            <!-- Left: Icon + Title + URL -->
            <div class="flex items-center gap-2 flex-1 min-w-0">
              <div class="p-1.5 rounded-lg shadow-sm" style="background-color: #007AFF;">
                <Calculator class="w-5 h-5 text-white" />
              </div>
              <div class="flex flex-col min-w-0">
                <span class="font-bold text-sm" style="color: #1e293b;">比价神器</span>
                <span class="text-xs truncate" style="color: #94a3b8;">jixiaoyong.github.io/price_pk</span>
              </div>
            </div>

            <!-- Right: QR Code -->
            <div class="flex-shrink-0">
              <img src="/qrcode.png" alt="QR Code" class="w-16 h-16" />
            </div>
          </div>
        </div>
      </div>
    </div>



    <!-- Confirm Dialog -->
    <ConfirmDialog v-if="showConfirm" title="确认操作" :message="confirmMessage" confirm-text="确认" type="danger"
      @confirm="confirmAction" @cancel="showConfirm = false" />

    <!-- Toast -->
    <Toast v-if="showToast" :message="toastMessage" :type="toastType" @close="showToast = false" />
  </div>
</template>

<style>
  /* No scoped styles needed, using global Tailwind classes */
</style>
