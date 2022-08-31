import XCTest

@testable import Atoms

@MainActor
final class AtomViewContextTests: XCTestCase {
    func testRead() {
        let atom = TestValueAtom(value: 100)
        let store = Store()
        let container = SubscriptionContainer()
        let context = AtomViewContext(
            store: StoreContext(store),
            container: container.wrapper,
            notifyUpdate: {}
        )

        XCTAssertEqual(context.read(atom), 100)
    }

    func testSet() {
        let atom = TestStateAtom(defaultValue: 100)
        let store = Store()
        let container = SubscriptionContainer()
        let context = AtomViewContext(
            store: StoreContext(store),
            container: container.wrapper,
            notifyUpdate: {}
        )

        XCTAssertEqual(context.watch(atom), 100)

        context.set(200, for: atom)

        XCTAssertEqual(context.watch(atom), 200)
    }

    func testRefresh() async {
        let atom = TestTaskAtom(value: 100)
        let store = Store()
        let container = SubscriptionContainer()
        let context = AtomViewContext(
            store: StoreContext(store),
            container: container.wrapper,
            notifyUpdate: {}
        )

        context.watch(atom)

        let value = await context.refresh(atom).value

        XCTAssertEqual(value, 100)
    }

    func testReset() {
        let atom = TestStateAtom(defaultValue: 0)
        let store = Store()
        let container = SubscriptionContainer()
        let context = AtomViewContext(
            store: StoreContext(store),
            container: container.wrapper,
            notifyUpdate: {}
        )

        XCTAssertEqual(context.watch(atom), 0)

        context[atom] = 100

        XCTAssertEqual(context.watch(atom), 100)

        context.reset(atom)

        XCTAssertEqual(context.read(atom), 0)
    }

    func testWatch() {
        let atom = TestStateAtom(defaultValue: 100)
        let store = Store()
        let container = SubscriptionContainer()
        let context = AtomViewContext(
            store: StoreContext(store),
            container: container.wrapper,
            notifyUpdate: {}
        )

        XCTAssertEqual(context.watch(atom), 100)

        context[atom] = 200

        XCTAssertEqual(context.watch(atom), 200)
    }

    func testUnsubscription() {
        let atom = TestValueAtom(value: 100)
        let key = AtomKey(atom)
        let store = Store()
        var container: SubscriptionContainer? = SubscriptionContainer()
        let context = AtomViewContext(
            store: StoreContext(store),
            container: container!.wrapper,
            notifyUpdate: {}
        )

        context.watch(atom)
        XCTAssertNotNil(store.state.atomCaches[key])

        container = nil
        XCTAssertNil(store.state.atomCaches[key])
    }
}
