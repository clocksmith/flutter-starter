import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/ui.dart';

import '../../../app/providers.dart';
import '../../../app/strings.dart';
import '../domain/task.dart';
import '../infrastructure/memory_task_server.dart';

class AccountActions extends ConsumerWidget {
  const AccountActions({super.key, required this.session});
  final SessionHandle session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final other = session.key.identity.accountId == 'A' ? 'B' : 'A';
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        TextButton(
          onPressed: () => unawaited(
            ref.read(sessionStateProvider.notifier).activate(other),
          ),
          child: Text(other == 'A' ? Strings.accountA : Strings.accountB),
        ),
        TextButton(
          onPressed: () =>
              unawaited(ref.read(sessionStateProvider.notifier).signOut()),
          child: const Text(Strings.signOut),
        ),
      ],
    );
  }
}

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key, required this.session});
  final SessionHandle session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(taskListProvider);
    final value = async.asData?.value;
    final data = value?.sessionKey == session.key ? value : null;
    final error =
        data?.failure ?? (async.hasError ? FailureKind.unexpected : null);
    return Scaffold(
      appBar: AppBar(title: const Text(Strings.tasks)),
      body: SingleChildScrollView(
        child: ContentArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                Strings.workspace,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 12),
              Text(
                Strings.taskHeading,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              Text(
                Strings.taskSubtitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              _TaskToolbar(
                session: session,
                refresh: () =>
                    unawaited(ref.read(taskRepositoryProvider)?.refreshList()),
              ),
              const SizedBox(height: 24),
              AsyncContent(
                loadingLabel: Strings.loading,
                emptyLabel: Strings.empty,
                retryLabel: Strings.retry,
                loading: data?.loading ?? async.isLoading,
                errorMessage: error == null ? null : Strings.failure(error),
                onRetry: () =>
                    unawaited(ref.read(taskRepositoryProvider)?.refreshList()),
                content: data == null || data.tasks.isEmpty
                    ? null
                    : Column(
                        children: [
                          for (final resource in data.tasks)
                            if (resource.task case final task?)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Card(
                                  child: InkWell(
                                    onTap: () => unawaited(
                                      Navigator.of(context).push<void>(
                                        MaterialPageRoute(
                                          builder: (_) => TaskDetailScreen(
                                            session: session,
                                            taskId: task.id,
                                          ),
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Row(
                                        children: [
                                          ExcludeSemantics(
                                            child: Icon(
                                              task.completed
                                                  ? Icons.check_circle_rounded
                                                  : Icons
                                                        .radio_button_unchecked_rounded,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  task.title,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                ),
                                                const SizedBox(height: 8),
                                                _TaskStatus(resource: resource),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 20,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({
    super.key,
    required this.session,
    required this.taskId,
  });
  final SessionHandle session;
  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(taskProvider(taskId));
    final value = async.asData?.value;
    final data = value?.sessionKey == session.key ? value : null;
    final error =
        data?.failure ?? (async.hasError ? FailureKind.unexpected : null);
    return Scaffold(
      appBar: AppBar(title: const Text(Strings.taskDetail)),
      body: SingleChildScrollView(
        child: ContentArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TaskToolbar(
                session: session,
                refresh: () => unawaited(
                  ref.read(taskRepositoryProvider)?.refresh(taskId),
                ),
              ),
              const SizedBox(height: 24),
              AsyncContent(
                loadingLabel: Strings.loading,
                emptyLabel: Strings.empty,
                retryLabel: Strings.retry,
                loading: data?.loading ?? async.isLoading,
                errorMessage: error == null ? null : Strings.failure(error),
                onRetry: () => unawaited(
                  ref.read(taskRepositoryProvider)?.refresh(taskId),
                ),
                content: data?.task == null
                    ? null
                    : _TaskForm(
                        resource: data!,
                        submit: (note) async {
                          final repository = ref.read(taskRepositoryProvider);
                          if (repository == null || !session.isActive) return;
                          try {
                            if (data.needsRetry) {
                              await repository.retryCompletion(taskId);
                            } else {
                              await repository.complete(taskId, note);
                            }
                          } on AppFailure {
                            // Repository state owns recovery; keep the draft in the form.
                          }
                        },
                        simulate: (behavior) {
                          ref.read(memoryServerProvider).nextCompletion =
                              behavior;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text(Strings.failureArmed)),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskForm extends HookWidget {
  const _TaskForm({
    required this.resource,
    required this.submit,
    required this.simulate,
  });
  final TaskResource resource;
  final Future<void> Function(String note) submit;
  final void Function(CompletionBehavior) simulate;

  @override
  Widget build(BuildContext context) {
    final input = useTextEditingController();
    useListenable(input);
    final task = resource.task!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TaskStatus(resource: resource),
        const SizedBox(height: 16),
        Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        if (task.completed && !resource.pending && !resource.needsRetry)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                task.note,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          )
        else ...[
          TextField(
            controller: input,
            readOnly: resource.pending || resource.needsRetry,
            decoration: const InputDecoration(
              labelText: Strings.note,
              hintText: Strings.noteHint,
            ),
            minLines: 2,
            maxLines: 5,
          ),
          SizedBox(height: UiSpacing.of(context).gap),
          ActionButton(
            label: resource.needsRetry
                ? Strings.retryCompletion
                : Strings.complete,
            pendingLabel: Strings.saving,
            pending: resource.pending,
            onPressed: input.text.trim().isEmpty && !resource.needsRetry
                ? null
                : () => unawaited(submit(input.text)),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            Strings.simulations,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: [
              TextButton(
                onPressed: resource.pending
                    ? null
                    : () => simulate(CompletionBehavior.reject),
                child: const Text(Strings.rejectNext),
              ),
              TextButton(
                onPressed: resource.pending
                    ? null
                    : () => simulate(CompletionBehavior.loseResponse),
                child: const Text(Strings.loseNext),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _TaskToolbar extends StatelessWidget {
  const _TaskToolbar({required this.session, required this.refresh});
  final SessionHandle session;
  final VoidCallback refresh;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.spaceBetween,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 12,
    runSpacing: 8,
    children: [
      AccountActions(session: session),
      TextButton.icon(
        onPressed: refresh,
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: const Text(Strings.refresh),
      ),
    ],
  );
}

class _TaskStatus extends StatelessWidget {
  const _TaskStatus({required this.resource});
  final TaskResource resource;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final completed = resource.task?.completed ?? false;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: completed
              ? colors.secondaryContainer
              : colors.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          resource.pending
              ? Strings.pending
              : completed
              ? Strings.completed
              : Strings.open,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: completed
                ? colors.onSecondaryContainer
                : colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
