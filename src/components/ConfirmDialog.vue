<script setup lang="ts">
    import { AlertTriangle } from 'lucide-vue-next';

    defineProps<{
        title?: string;
        message: string;
        confirmText?: string;
        cancelText?: string;
        danger?: boolean;
    }>();

    const emit = defineEmits(['confirm', 'cancel']);
</script>

<template>
    <Teleport to="body">
        <div class="confirm-overlay" @click.self="emit('cancel')">
            <div class="confirm-dialog glass-panel">
                <div class="dialog-icon" :class="{ danger }">
                    <AlertTriangle :size="32" />
                </div>
                <h3 class="dialog-title">{{ title || '确认操作' }}</h3>
                <p class="dialog-message">{{ message }}</p>
                <div class="dialog-actions">
                    <button class="btn cancel-btn" @click="emit('cancel')">
                        {{ cancelText || '取消' }}
                    </button>
                    <button class="btn confirm-btn" :class="{ danger }" @click="emit('confirm')">
                        {{ confirmText || '确定' }}
                    </button>
                </div>
            </div>
        </div>
    </Teleport>
</template>

<style scoped>
    .confirm-overlay {
        position: fixed;
        inset: 0;
        background: rgba(0, 0, 0, 0.4);
        backdrop-filter: blur(4px);
        z-index: 2000;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 1.5rem;
    }

    .confirm-dialog {
        width: 100%;
        max-width: 320px;
        border-radius: 20px;
        padding: 1.5rem;
        text-align: center;
    }

    .dialog-icon {
        width: 56px;
        height: 56px;
        border-radius: 50%;
        background: rgba(59, 130, 246, 0.1);
        color: var(--primary);
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 1rem;
    }

    .dialog-icon.danger {
        background: rgba(239, 68, 68, 0.1);
        color: var(--danger);
    }

    .dialog-title {
        margin: 0 0 0.5rem;
        font-size: 1.1rem;
        font-weight: 600;
    }

    .dialog-message {
        margin: 0 0 1.5rem;
        font-size: 0.9rem;
        color: var(--text-muted);
        line-height: 1.5;
    }

    .dialog-actions {
        display: flex;
        gap: 0.75rem;
    }

    .btn {
        flex: 1;
        padding: 12px;
        border-radius: 12px;
        font-weight: 600;
        font-size: 0.9rem;
    }

    .cancel-btn {
        background: var(--glass-bg);
        border: 1px solid var(--glass-border);
        color: var(--text-muted);
    }

    .confirm-btn {
        background: var(--primary-gradient);
        color: white;
    }

    .confirm-btn.danger {
        background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
    }
</style>
