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
              AccountActions(session: session),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: () => unawaited(
                    ref.read(taskRepositoryProvider)?.refreshList(),
                  ),
                  child: const Text(Strings.refresh),
                ),
              ),
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
                              Card(
                                child: ListTile(
                                  title: Text(task.title),
                                  subtitle: Text(
                                    resource.pending
                                        ? Strings.pending
                                        : task.completed
                                        ? Strings.completed
                                        : Strings.open,
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
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
      appBar: AppBar(title: const Text(Strings.tasks)),
      body: SingleChildScrollView(
        child: ContentArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AccountActions(session: session),
              TextButton(
                onPressed: () => unawaited(
                  ref.read(taskRepositoryProvider)?.refresh(taskId),
                ),
                child: const Text(Strings.refresh),
              ),
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
        Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
        SizedBox(height: UiSpacing.of(context).gap),
        Text(
          resource.pending
              ? Strings.pending
              : task.completed
              ? Strings.completed
              : Strings.open,
        ),
        SizedBox(height: UiSpacing.of(context).gap),
        if (task.completed && !resource.pending && !resource.needsRetry)
          Text(task.note)
        else ...[
          TextField(
            controller: input,
            readOnly: resource.pending || resource.needsRetry,
            decoration: const InputDecoration(labelText: Strings.note),
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
