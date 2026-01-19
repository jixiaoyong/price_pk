<script setup lang="ts">
  import { ref, onMounted } from 'vue';
  import { usePriceStore } from './stores/usePriceStore';
  import CategoryTabs from './components/CategoryTabs.vue';
  import GoodsCard from './components/GoodsCard.vue';
  import ActionBar from './components/ActionBar.vue';
  import ScreenshotOverlay from './components/ScreenshotOverlay.vue';
  import { useRegisterSW } from 'virtual:pwa-register/vue';

  const store = usePriceStore();
  const showScreenshot = ref(false);

  // Register Service Worker for PWA
  const { needRefresh, updateServiceWorker } = useRegisterSW();

  onMounted(() => {
    // 优先从 URL 加载数据，如果没有则从 localStorage 恢复
    const params = new URLSearchParams(window.location.search);
    if (params.has('d')) {
      store.loadFromUrl(params.get('d')!);
    } else {
      store.loadFromLocalStorage();
    }
  });

  const onScreenshot = () => {
    showScreenshot.value = true;
  };
</script>

<template>
  <div class="app-container">
    <header class="header">
      <h1 class="title">性价比大PK</h1>
      <p class="subtitle">单位价格实时比对工具</p>
    </header>

    <main class="content" id="capture-area">
      <CategoryTabs />

      <div class="goods-list">
        <TransitionGroup name="list">
          <GoodsCard v-for="item in store.currentCategory.items" :key="item.id" :item="item"
            :category="store.currentCategory"
            :is-cheapest="store.minUnitPrice !== Infinity && store.calculateUnitPrice(item, store.currentCategory) !== Infinity && store.calculateUnitPrice(item, store.currentCategory) === store.minUnitPrice" />
        </TransitionGroup>
      </div>

      <!-- Spacer for bottom action bar -->
      <div style="height: 100px;"></div>
    </main>

    <ActionBar @screenshot="onScreenshot" />

    <ScreenshotOverlay v-if="showScreenshot" target-id="capture-area" @close="showScreenshot = false" />

    <!-- PWA Update Notification -->
    <div v-if="needRefresh" class="pwa-toast glass-panel">
      <span>发现新版本，立即更新？</span>
      <button @click="updateServiceWorker()">更新</button>
    </div>
  </div>
</template>

<style scoped>
  .app-container {
    padding: 1.5rem;
    padding-bottom: env(safe-area-inset-bottom);
  }

  .header {
    text-align: center;
    margin-bottom: 2rem;
  }

  .title {
    margin: 0;
    font-size: 1.75rem;
    font-weight: 800;
    background: var(--primary-gradient);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  }

  .subtitle {
    margin: 0.25rem 0 0;
    font-size: 0.9rem;
    color: var(--text-muted);
  }

  .goods-list {
    display: flex;
    flex-direction: column;
  }

  /* List Transitions */
  .list-move,
  .list-enter-active,
  .list-leave-active {
    transition: all 0.5s ease;
  }

  .list-enter-from,
  .list-leave-to {
    opacity: 0;
    transform: translateX(30px);
  }

  .list-leave-active {
    position: absolute;
    width: 100%;
  }

  .pwa-toast {
    position: fixed;
    right: 1.5rem;
    bottom: 6rem;
    padding: 12px 20px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    gap: 1rem;
    z-index: 1000;
    animation: slideUp 0.3s ease;
  }

  .pwa-toast button {
    padding: 6px 16px;
    background: var(--primary);
    color: white;
    border-radius: 6px;
    font-size: 0.85rem;
  }

  @keyframes slideUp {
    from {
      transform: translateY(100%);
      opacity: 0;
    }

    to {
      transform: translateY(0);
      opacity: 1;
    }
  }
</style>
