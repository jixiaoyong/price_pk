<script setup lang="ts">
    import { ref, onMounted, onUnmounted } from 'vue';
    import { CheckCircle, Info, AlertTriangle, XCircle, X } from 'lucide-vue-next';

    const props = defineProps<{
        message: string;
        type?: 'success' | 'info' | 'warning' | 'error';
        duration?: number;
    }>();

    const emit = defineEmits(['close']);

    const visible = ref(true);

    const iconMap = {
        success: CheckCircle,
        info: Info,
        warning: AlertTriangle,
        error: XCircle,
    };

    const icon = iconMap[props.type || 'info'];

    let timer: ReturnType<typeof setTimeout>;

    onMounted(() => {
        timer = setTimeout(() => {
            visible.value = false;
            emit('close');
        }, props.duration || 3000);
    });

    onUnmounted(() => {
        clearTimeout(timer);
    });

    const onClose = () => {
        visible.value = false;
        emit('close');
    };
</script>

<template>
    <Teleport to="body">
        <Transition name="toast">
            <div v-if="visible" class="toast-container" :class="type || 'info'">
                <component :is="icon" :size="20" class="toast-icon" />
                <span class="toast-message">{{ message }}</span>
                <button class="toast-close" @click="onClose">
                    <X :size="16" />
                </button>
            </div>
        </Transition>
    </Teleport>
</template>

<style scoped>
    .toast-container {
        position: fixed;
        top: 1.5rem;
        left: 50%;
        transform: translateX(-50%);
        display: flex;
        align-items: center;
        gap: 0.75rem;
        padding: 12px 16px;
        border-radius: 12px;
        background: white;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
        z-index: 3000;
        max-width: 90vw;
    }

    .toast-container.success {
        background: linear-gradient(135deg, #10b981 0%, #059669 100%);
        color: white;
    }

    .toast-container.info {
        background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
        color: white;
    }

    .toast-container.warning {
        background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
        color: white;
    }

    .toast-container.error {
        background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
        color: white;
    }

    .toast-icon {
        flex-shrink: 0;
    }

    .toast-message {
        font-size: 0.9rem;
        font-weight: 500;
    }

    .toast-close {
        background: transparent;
        color: inherit;
        opacity: 0.7;
        padding: 4px;
        margin-left: 8px;
    }

    .toast-close:hover {
        opacity: 1;
    }

    /* Transition */
    .toast-enter-active,
    .toast-leave-active {
        transition: all 0.3s ease;
    }

    .toast-enter-from,
    .toast-leave-to {
        opacity: 0;
        transform: translateX(-50%) translateY(-20px);
    }
</style>
