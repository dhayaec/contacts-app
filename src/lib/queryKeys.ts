export const queryKeys = {
  todos: {
    all: ['todos'] as const,
    list: () => [...queryKeys.todos.all, 'list'] as const,
    detail: (id: number) => [...queryKeys.todos.all, 'detail', id] as const,
  },
};
