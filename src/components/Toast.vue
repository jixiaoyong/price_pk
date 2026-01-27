<script setup lang="ts">
    import { Check, AlertCircle, Info } from 'lucide-vue-next';
    import { onMounted, onUnmounted } from 'vue';

    const props = defineProps<{
        message: string;
        type?: 'success' | 'error' | 'info';
        duration?: number;
    }>();

    const emit = defineEmits(['close']);

    const icons = {
        success: Check,
        error: AlertCircle,
        info: Info
    };

    const config = {
        success: {
            bg: 'rgba(52, 199, 89, 0.9)',
            icon: '#ffffff'
        },
        error: {
            bg: 'rgba(255, 59, 48, 0.9)',
            icon: '#ffffff'
        },
        info: {
            bg: 'rgba(0, 122, 255, 0.9)',
            icon: '#ffffff'
        }
    };

    let timer: number;

    onMounted(() => {
        if (props.duration !== 0) {
            timer = window.setTimeout(() => {
                emit('close');
            }, props.duration || 2000);
        }
    });

    onUnmounted(() => {
        clearTimeout(timer);
    });
</script>

<template>
    <div class="fixed bottom-24 left-1/2 -translate-x-1/2 z-[100] flex items-center gap-2 px-4 py-2.5 rounded-full shadow-lg animate-in slide-in-from-bottom-4 fade-in duration-300 backdrop-blur-xl min-w-[200px] justify-center"
        :style="{ backgroundColor: config[type || 'success'].bg }">
        <component :is="icons[type || 'success']" class="w-5 h-5" :style="{ color: config[type || 'success'].icon }" />
        <span class="text-sm font-semibold text-white">{{ message }}</span>
    </div>
</template>
